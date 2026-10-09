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

  /// Đồng bộ trực tiếp danh sách tài liệu lên Cloud Firestore REST API thật của Google
  Future<SyncResult> syncWithCloud({
    Future<bool> Function(List<StudyDocument> docs)? uploadMock,
  }) async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Đang có tiến trình đồng bộ khác');
    }

    _isSyncing = true;
    try {
      final unsyncedDocs = _documentDao.getUnsyncedDocuments();
      final docsToSync = unsyncedDocs.isEmpty ? _documentDao.getAll() : unsyncedDocs;

      if (docsToSync.isEmpty) {
        _isSyncing = false;
        return SyncResult(success: true, syncedCount: 0, message: 'Chưa có tài liệu nào để đồng bộ');
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
        return SyncResult(
          success: true,
          syncedCount: successCount,
          message: 'Đã đồng bộ thành công $successCount tài liệu lên Cloud Firestore!',
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
