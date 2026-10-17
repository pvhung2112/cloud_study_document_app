enum BorrowStatus { pending, approved, rejected, returned, cancelled }

extension BorrowStatusExt on BorrowStatus {
  String get displayName {
    switch (this) {
      case BorrowStatus.pending:
        return 'Chờ duyệt';
      case BorrowStatus.approved:
        return 'Đã duyệt';
      case BorrowStatus.rejected:
        return 'Từ chối';
      case BorrowStatus.returned:
        return 'Đã trả';
      case BorrowStatus.cancelled:
        return 'Đã hủy';
    }
  }

  static BorrowStatus fromString(String s) {
    return BorrowStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => BorrowStatus.pending,
    );
  }
}

enum SharePermission { view, comment, edit }

extension SharePermissionExt on SharePermission {
  String get displayName {
    switch (this) {
      case SharePermission.view:
        return 'Chỉ xem';
      case SharePermission.comment:
        return 'Xem & Bình luận';
      case SharePermission.edit:
        return 'Chỉnh sửa';
    }
  }

  static SharePermission fromString(String s) {
    return SharePermission.values.firstWhere(
      (e) => e.name == s,
      orElse: () => SharePermission.view,
    );
  }
}

/// Yêu cầu mượn tài liệu vật lý
class BorrowRequest {
  final String id;
  final String documentId;
  final String documentTitle;
  final String requesterName;
  final String requesterEmail;
  final String ownerName;
  final BorrowStatus status;
  final DateTime requestedAt;
  final DateTime? dueDate;
  final DateTime? returnedAt;
  final String note;

  const BorrowRequest({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.requesterName,
    required this.requesterEmail,
    required this.ownerName,
    this.status = BorrowStatus.pending,
    required this.requestedAt,
    this.dueDate,
    this.returnedAt,
    this.note = '',
  });

  BorrowRequest copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? requesterName,
    String? requesterEmail,
    String? ownerName,
    BorrowStatus? status,
    DateTime? requestedAt,
    DateTime? dueDate,
    DateTime? returnedAt,
    String? note,
  }) {
    return BorrowRequest(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      requesterName: requesterName ?? this.requesterName,
      requesterEmail: requesterEmail ?? this.requesterEmail,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'document_id': documentId,
        'document_title': documentTitle,
        'requester_name': requesterName,
        'requester_email': requesterEmail,
        'owner_name': ownerName,
        'status': status.name,
        'requested_at': requestedAt.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'returned_at': returnedAt?.toIso8601String(),
        'note': note,
      };

  factory BorrowRequest.fromMap(Map<String, dynamic> map) {
    return BorrowRequest(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      documentTitle: map['document_title'] as String,
      requesterName: map['requester_name'] as String,
      requesterEmail: map['requester_email'] as String,
      ownerName: map['owner_name'] as String,
      status: BorrowStatusExt.fromString(map['status'] as String? ?? 'pending'),
      requestedAt: DateTime.parse(map['requested_at'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      returnedAt: map['returned_at'] != null ? DateTime.parse(map['returned_at'] as String) : null,
      note: map['note'] as String? ?? '',
    );
  }
}

/// Quyền truy cập tài liệu được chia sẻ
class SharedAccess {
  final String id;
  final String documentId;
  final String documentTitle;
  final String sharedToName;
  final String sharedToEmail;
  final String sharedByName;
  final SharePermission permission;
  final DateTime sharedAt;
  final DateTime? expiresAt;
  final bool isActive;

  const SharedAccess({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.sharedToName,
    required this.sharedToEmail,
    required this.sharedByName,
    required this.permission,
    required this.sharedAt,
    this.expiresAt,
    this.isActive = true,
  });

  SharedAccess copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? sharedToName,
    String? sharedToEmail,
    String? sharedByName,
    SharePermission? permission,
    DateTime? sharedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return SharedAccess(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      sharedToName: sharedToName ?? this.sharedToName,
      sharedToEmail: sharedToEmail ?? this.sharedToEmail,
      sharedByName: sharedByName ?? this.sharedByName,
      permission: permission ?? this.permission,
      sharedAt: sharedAt ?? this.sharedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'document_id': documentId,
        'document_title': documentTitle,
        'shared_to_name': sharedToName,
        'shared_to_email': sharedToEmail,
        'shared_by_name': sharedByName,
        'permission': permission.name,
        'shared_at': sharedAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'is_active': isActive ? 1 : 0,
      };

  factory SharedAccess.fromMap(Map<String, dynamic> map) {
    return SharedAccess(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      documentTitle: map['document_title'] as String,
      sharedToName: map['shared_to_name'] as String,
      sharedToEmail: map['shared_to_email'] as String,
      sharedByName: map['shared_by_name'] as String,
      permission: SharePermissionExt.fromString(map['permission'] as String? ?? 'view'),
      sharedAt: DateTime.parse(map['shared_at'] as String),
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at'] as String) : null,
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }
}
