import 'dart:async';
import '../struct/borrowRequest.dart';
import 'package:uuid/uuid.dart';

/// Service quản lý luồng nghiệp vụ Mượn & Chia sẻ tài liệu
class BorrowShareService {
  static final BorrowShareService _instance = BorrowShareService._internal();
  factory BorrowShareService() => _instance;
  BorrowShareService._internal() {
    _seedSampleData();
  }

  final _uuid = const Uuid();
  final Map<String, BorrowRequest> _borrowRequests = {};
  final Map<String, SharedAccess> _sharedAccesses = {};

  final _borrowController = StreamController<List<BorrowRequest>>.broadcast();
  final _shareController = StreamController<List<SharedAccess>>.broadcast();

  Stream<List<BorrowRequest>> get borrowStream => _borrowController.stream;
  Stream<List<SharedAccess>> get shareStream => _shareController.stream;

  void _notifyBorrow() => _borrowController.add(getAllBorrowRequests());
  void _notifyShare() => _shareController.add(getAllSharedAccesses());

  // ─────────── BORROW REQUESTS ───────────

  /// Tạo yêu cầu mượn tài liệu mới
  Future<BorrowRequest> createBorrowRequest({
    required String documentId,
    required String documentTitle,
    required String requesterName,
    required String requesterEmail,
    String ownerName = 'Thư viện FPT',
    DateTime? dueDate,
    String note = '',
  }) async {
    final req = BorrowRequest(
      id: _uuid.v4(),
      documentId: documentId,
      documentTitle: documentTitle,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      ownerName: ownerName,
      status: BorrowStatus.pending,
      requestedAt: DateTime.now(),
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 14)),
      note: note,
    );
    _borrowRequests[req.id] = req;
    _notifyBorrow();
    return req;
  }

  /// Duyệt yêu cầu mượn
  Future<void> approveBorrow(String requestId) async {
    final req = _borrowRequests[requestId];
    if (req == null) return;
    _borrowRequests[requestId] = req.copyWith(status: BorrowStatus.approved);
    _notifyBorrow();
  }

  /// Từ chối yêu cầu mượn
  Future<void> rejectBorrow(String requestId) async {
    final req = _borrowRequests[requestId];
    if (req == null) return;
    _borrowRequests[requestId] = req.copyWith(status: BorrowStatus.rejected);
    _notifyBorrow();
  }

  /// Đánh dấu đã trả tài liệu
  Future<void> markReturned(String requestId) async {
    final req = _borrowRequests[requestId];
    if (req == null) return;
    _borrowRequests[requestId] = req.copyWith(
      status: BorrowStatus.returned,
      returnedAt: DateTime.now(),
    );
    _notifyBorrow();
  }

  /// Hủy yêu cầu mượn
  Future<void> cancelBorrow(String requestId) async {
    final req = _borrowRequests[requestId];
    if (req == null) return;
    _borrowRequests[requestId] = req.copyWith(status: BorrowStatus.cancelled);
    _notifyBorrow();
  }

  List<BorrowRequest> getAllBorrowRequests() {
    final list = _borrowRequests.values.toList();
    list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return list;
  }

  List<BorrowRequest> getBorrowRequestsByStatus(BorrowStatus status) {
    return getAllBorrowRequests().where((r) => r.status == status).toList();
  }

  // ─────────── SHARED ACCESS ───────────

  /// Chia sẻ quyền truy cập tài liệu cho người dùng khác
  Future<SharedAccess> shareDocument({
    required String documentId,
    required String documentTitle,
    required String sharedToName,
    required String sharedToEmail,
    String sharedByName = 'Bạn',
    SharePermission permission = SharePermission.view,
    DateTime? expiresAt,
  }) async {
    final access = SharedAccess(
      id: _uuid.v4(),
      documentId: documentId,
      documentTitle: documentTitle,
      sharedToName: sharedToName,
      sharedToEmail: sharedToEmail,
      sharedByName: sharedByName,
      permission: permission,
      sharedAt: DateTime.now(),
      expiresAt: expiresAt,
      isActive: true,
    );
    _sharedAccesses[access.id] = access;
    _notifyShare();
    return access;
  }

  /// Cập nhật quyền truy cập
  Future<void> updatePermission(String accessId, SharePermission newPermission) async {
    final acc = _sharedAccesses[accessId];
    if (acc == null) return;
    _sharedAccesses[accessId] = acc.copyWith(permission: newPermission);
    _notifyShare();
  }

  /// Thu hồi quyền truy cập
  Future<void> revokeAccess(String accessId) async {
    final acc = _sharedAccesses[accessId];
    if (acc == null) return;
    _sharedAccesses[accessId] = acc.copyWith(isActive: false);
    _notifyShare();
  }

  List<SharedAccess> getAllSharedAccesses() {
    final list = _sharedAccesses.values.toList();
    list.sort((a, b) => b.sharedAt.compareTo(a.sharedAt));
    return list;
  }

  List<SharedAccess> getActiveSharedAccesses() {
    return getAllSharedAccesses().where((a) => a.isActive).toList();
  }

  List<SharedAccess> getSharedForDocument(String documentId) {
    return getActiveSharedAccesses().where((a) => a.documentId == documentId).toList();
  }

  // ─────────── SAMPLE DATA ───────────
  void _seedSampleData() {
    final req1 = BorrowRequest(
      id: 'br-1',
      documentId: 'doc-1',
      documentTitle: 'Bài tập lớn: Thiết kế mô-đun Sync Engine',
      requesterName: 'Nguyễn Văn Bình',
      requesterEmail: 'binh.nv@fpt.edu.vn',
      ownerName: 'Thư viện FPT',
      status: BorrowStatus.pending,
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      note: 'Cần mượn để làm bài tập lớn môn SE301',
    );
    final req2 = BorrowRequest(
      id: 'br-2',
      documentId: 'doc-2',
      documentTitle: 'Slide Chương 4: Phân tích Kiến trúc Cashew',
      requesterName: 'Trần Thị Lan',
      requesterEmail: 'lan.tt@fpt.edu.vn',
      ownerName: 'Thư viện FPT',
      status: BorrowStatus.approved,
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
    );
    final req3 = BorrowRequest(
      id: 'br-3',
      documentId: 'doc-3',
      documentTitle: 'Giáo trình Flutter Cookbook',
      requesterName: 'Lê Minh Tuấn',
      requesterEmail: 'tuan.lm@fpt.edu.vn',
      ownerName: 'Thư viện FPT',
      status: BorrowStatus.returned,
      requestedAt: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      returnedAt: DateTime.now().subtract(const Duration(days: 4)),
    );
    _borrowRequests[req1.id] = req1;
    _borrowRequests[req2.id] = req2;
    _borrowRequests[req3.id] = req3;

    final share1 = SharedAccess(
      id: 'sa-1',
      documentId: 'doc-1',
      documentTitle: 'Bài tập lớn: Thiết kế mô-đun Sync Engine',
      sharedToName: 'Nhóm SE301 - Nhóm 3',
      sharedToEmail: 'group3.se301@fpt.edu.vn',
      sharedByName: 'Bạn',
      permission: SharePermission.comment,
      sharedAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
    );
    final share2 = SharedAccess(
      id: 'sa-2',
      documentId: 'doc-2',
      documentTitle: 'Slide Chương 4: Phân tích Kiến trúc Cashew',
      sharedToName: 'Phạm Thanh Hoa',
      sharedToEmail: 'hoa.pt@fpt.edu.vn',
      sharedByName: 'Bạn',
      permission: SharePermission.view,
      sharedAt: DateTime.now().subtract(const Duration(days: 3)),
      isActive: true,
    );
    _sharedAccesses[share1.id] = share1;
    _sharedAccesses[share2.id] = share2;
  }
}
