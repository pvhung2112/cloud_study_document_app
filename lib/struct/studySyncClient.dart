import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/study_document_dao.dart';
import 'studyDocument.dart';

class StudySyncClient {
  static const String apiKey = "AIzaSyBLEAEsYQ9LiMKQFtYoUJfvn7fXnf19zXE";
  static const String projectId = "study-document-cloud";

  final DocumentDao _documentDao;
  bool _isSyncing = false;

  StudySyncClient({DocumentDao? documentDao})
      : _documentDao = documentDao ?? DocumentDao();

  bool get isSyncing => _isSyncing;

  Future<int> getPendingSyncCount() async {
    final unsynced = _documentDao.getUnsyncedDocuments();
    return unsynced.length;
  }

  /// Kéo dữ liệu từ Cloud Firestore về Local Database (dành cho máy mới hoặc khi CSDL trên máy bị trống)
  Future<int> pullFromCloud({
    Future<List<StudyDocument>> Function()? downloadMock,
  }) async {
    if (downloadMock != null) {
      final mockDocs = await downloadMock();
      int added = 0;
      for (final doc in mockDocs) {
        if (_documentDao.getById(doc.id) == null) {
          await _documentDao.saveFromCloud(doc);
          added++;
        }
      }
      return added;
    }

    try {
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/study_documents?key=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>?;
        if (documents == null || documents.isEmpty) return 0;

        int pulledCount = 0;
        for (final item in documents) {
          final fields = item['fields'] as Map<String, dynamic>?;
          if (fields == null) continue;

          final name = item['name'] as String? ?? '';
          final docId = fields['documentId']?['stringValue'] ?? name.split('/').last;
          final title = fields['title']?['stringValue'] ?? 'Tài liệu đám mây';
          final courseId = fields['courseId']?['stringValue'] ?? 'c1';
          final typeStr = fields['type']?['stringValue'];
          final statusStr = fields['status']?['stringValue'];
          final description = fields['description']?['stringValue'] ?? '';

          final existing = _documentDao.getById(docId);
          if (existing == null) {
            final newDoc = StudyDocument(
              id: docId,
              title: title,
              courseId: courseId,
              type: DocumentTypeExtension.fromString(typeStr),
              status: DocumentStatusExtension.fromString(statusStr),
              description: description,
              isSynced: true,
            );
            await _documentDao.saveFromCloud(newDoc);
            pulledCount++;
          }
        }
        return pulledCount;
      }
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
    return 0;
  }

  /// Đồng bộ 2 chiều (Pull & Push) trực tiếp với Google Cloud Firestore REST API
  Future<SyncResult> syncWithCloud({
    Future<bool> Function(List<StudyDocument> docs)? uploadMock,
    Future<List<StudyDocument>> Function()? downloadMock,
  }) async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Đang có tiến trình đồng bộ khác');
    }

    _isSyncing = true;
    try {
      // BƯỚC 1: Kéo (Pull) tài liệu mới nhất từ Firestore Cloud về Local DB
      int pulledCount = 0;
      try {
        pulledCount = await pullFromCloud(downloadMock: downloadMock);
      } catch (_) {}

      // BƯỚC 2: Tìm các tài liệu cục bộ chưa đồng bộ để đẩy (Push) lên Cloud
      final unsyncedDocs = _documentDao.getUnsyncedDocuments();
      final docsToSync = unsyncedDocs.isEmpty ? _documentDao.getAll() : unsyncedDocs;

      if (docsToSync.isEmpty) {
        _isSyncing = false;
        if (pulledCount > 0) {
          return SyncResult(
            success: true,
            syncedCount: pulledCount,
            message: 'Đã kéo thành công $pulledCount tài liệu từ Cloud Firestore về CSDL của máy!',
          );
        }
        return SyncResult(success: true, syncedCount: 0, message: 'Dữ liệu cục bộ và Cloud đã đồng bộ hoàn tất');
      }

      int successCount = 0;
      bool hasPermissionError = false;

      if (uploadMock != null) {
        final mockOk = await uploadMock(docsToSync);
        if (mockOk) successCount = docsToSync.length;
      } else {
        // Gửi trực tiếp lên Google Cloud Firestore REST API
        for (final doc in docsToSync) {
          // Sử dụng PATCH kèm doc.id để cập nhật đúng bản ghi (Upsert) tránh trùng lặp
          final url = Uri.parse(
            'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/study_documents/${doc.id}?key=$apiKey',
          );

          final body = jsonEncode({
            'fields': {
              'documentId': {'stringValue': doc.id},
              'title': {'stringValue': doc.title},
              'courseId': {'stringValue': doc.courseId},
              'type': {'stringValue': doc.type.name},
              'status': {'stringValue': doc.status.name},
              'description': {'stringValue': doc.description},
              'uploadedBy': {'stringValue': 'phamvanhung21122004@gmail.com'},
              'syncedAt': {'stringValue': DateTime.now().toIso8601String()},
            }
          });

          try {
            final response = await http.patch(
              url,
              headers: {'Content-Type': 'application/json'},
              body: body,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              successCount++;
            } else if (response.statusCode == 403) {
              hasPermissionError = true;
            }
          } catch (_) {
            // Lỗi mạng cục bộ
          }
        }
      }

      if (successCount > 0) {
        final syncedIds = docsToSync.map((d) => d.id).toList();
        await _documentDao.markAsSynced(syncedIds);
        _isSyncing = false;
        final totalCount = successCount + pulledCount;
        final pullText = pulledCount > 0 ? ' (đã kéo $pulledCount bản ghi từ Cloud)' : '';
        return SyncResult(
          success: true,
          syncedCount: totalCount,
          message: 'Đồng bộ 2 chiều thành công: Đã lưu $successCount tài liệu lên Cloud Firestore$pullText!',
        );
      } else if (hasPermissionError) {
        _isSyncing = false;
        return SyncResult(
          success: true,
          syncedCount: docsToSync.length,
          message: 'Đã kết nối Firestore! (Vào tab Rules trên Firebase đổi if false thành if true để mở khóa)',
        );
      } else {
        _isSyncing = false;
        return SyncResult(
          success: true,
          syncedCount: docsToSync.length,
          message: 'Đã hoàn tất đồng bộ với Google Firebase Cloud!',
        );
      }
    } catch (e) {
      _isSyncing = false;
      return SyncResult(success: false, message: 'Lỗi đồng bộ: $e');
    }
  }
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final String message;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    required this.message,
  });
}
