import 'package:flutter/material.dart';
import '../struct/borrowRequest.dart';
import '../services/borrowShareService.dart';
import '../struct/studyDocument.dart';
import '../database/study_document_dao.dart';
import 'package:intl/intl.dart';

/// Trang quản lý luồng Mượn & Chia sẻ tài liệu
class BorrowSharePage extends StatefulWidget {
  const BorrowSharePage({super.key});

  @override
  State<BorrowSharePage> createState() => _BorrowSharePageState();
}

class _BorrowSharePageState extends State<BorrowSharePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final BorrowShareService _service = BorrowShareService();
  final DocumentDao _docDao = DocumentDao();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD81B60),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.request_page_rounded),
        label: const Text('Yêu cầu mượn'),
        onPressed: () => _showBorrowRequestDialog(context),
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mượn & Chia sẻ',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                            ),
                            Text(
                              'Quản lý yêu cầu mượn và quyền truy cập tài liệu',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<List<BorrowRequest>>(
                        stream: _service.borrowStream,
                        initialData: _service.getAllBorrowRequests(),
                        builder: (ctx, snap) {
                          final pending = (snap.data ?? []).where((r) => r.status == BorrowStatus.pending).length;
                          if (pending == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD81B60),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$pending chờ duyệt',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  StreamBuilder<List<BorrowRequest>>(
                    stream: _service.borrowStream,
                    initialData: _service.getAllBorrowRequests(),
                    builder: (ctx, snap) {
                      final reqs = snap.data ?? [];
                      return _buildStatsRow(reqs, theme);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFF7D8DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: const Color(0xFFD81B60),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(icon: Icon(Icons.swap_horiz_rounded, size: 16), text: 'Yêu cầu mượn'),
                    Tab(icon: Icon(Icons.share_rounded, size: 16), text: 'Chia sẻ quyền truy cập'),
                  ],
                ),
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BorrowRequestsTab(service: _service),
                _SharedAccessTab(service: _service),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<BorrowRequest> reqs, ThemeData theme) {
    final pending = reqs.where((r) => r.status == BorrowStatus.pending).length;
    final approved = reqs.where((r) => r.status == BorrowStatus.approved).length;
    final returned = reqs.where((r) => r.status == BorrowStatus.returned).length;

    return Row(
      children: [
        _StatCard(value: '$pending', label: 'Chờ duyệt', color: Colors.orange, icon: Icons.hourglass_empty_rounded),
        const SizedBox(width: 10),
        _StatCard(value: '$approved', label: 'Đã duyệt', color: Colors.green, icon: Icons.check_circle_rounded),
        const SizedBox(width: 10),
        _StatCard(value: '$returned', label: 'Đã trả', color: Colors.blue, icon: Icons.assignment_returned_rounded),
      ],
    );
  }

  Future<void> _showBorrowRequestDialog(BuildContext context) async {
    final docs = _docDao.getAll();
    await showDialog(
      context: context,
      builder: (ctx) => _BorrowRequestDialog(
        documents: docs,
        service: _service,
      ),
    );
  }
}

// ─────────── Borrow Requests Tab ───────────
class _BorrowRequestsTab extends StatelessWidget {
  final BorrowShareService service;
  const _BorrowRequestsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BorrowRequest>>(
      stream: service.borrowStream,
      initialData: service.getAllBorrowRequests(),
      builder: (ctx, snap) {
        final reqs = snap.data ?? [];
        if (reqs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('Chưa có yêu cầu mượn nào', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: reqs.length,
          itemBuilder: (ctx, i) => _BorrowRequestCard(request: reqs[i], service: service),
        );
      },
    );
  }
}

// ─────────── Shared Access Tab ───────────
class _SharedAccessTab extends StatelessWidget {
  final BorrowShareService service;
  const _SharedAccessTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SharedAccess>>(
      stream: service.shareStream,
      initialData: service.getAllSharedAccesses(),
      builder: (ctx, snap) {
        final accesses = snap.data ?? [];
        if (accesses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_rounded, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('Chưa chia sẻ tài liệu nào', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: accesses.length,
          itemBuilder: (ctx, i) => _SharedAccessCard(access: accesses[i], service: service),
        );
      },
    );
  }
}

// ─────────── Borrow Request Card ───────────
class _BorrowRequestCard extends StatelessWidget {
  final BorrowRequest request;
  final BorrowShareService service;

  const _BorrowRequestCard({required this.request, required this.service});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final fmt = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.assignment_rounded, color: statusColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.documentTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Người yêu cầu: ${request.requesterName}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.email_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(request.requesterEmail, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(fmt.format(request.requestedAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            if (request.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event_available_rounded, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text('Hạn trả: ${fmt.format(request.dueDate!)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Expanded(child: Text(request.note, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
                  ],
                ),
              ),
            ],
            if (request.status == BorrowStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => service.rejectBorrow(request.id),
                      icon: const Icon(Icons.close_rounded, size: 14),
                      label: const Text('Từ chối', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => service.approveBorrow(request.id),
                      icon: const Icon(Icons.check_rounded, size: 14),
                      label: const Text('Duyệt', style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (request.status == BorrowStatus.approved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => service.markReturned(request.id),
                  icon: const Icon(Icons.assignment_return_rounded, size: 14),
                  label: const Text('Đánh dấu đã trả'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(BorrowStatus s) {
    switch (s) {
      case BorrowStatus.pending: return Colors.orange;
      case BorrowStatus.approved: return Colors.green;
      case BorrowStatus.rejected: return Colors.red;
      case BorrowStatus.returned: return Colors.blue;
      case BorrowStatus.cancelled: return Colors.grey;
    }
  }
}

// ─────────── Shared Access Card ───────────
class _SharedAccessCard extends StatelessWidget {
  final SharedAccess access;
  final BorrowShareService service;

  const _SharedAccessCard({required this.access, required this.service});

  @override
  Widget build(BuildContext context) {
    final permColor = _permColor(access.permission);
    final fmt = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: access.isActive ? permColor.withOpacity(0.3) : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: permColor.withOpacity(0.15),
                  child: Text(
                    access.sharedToName[0].toUpperCase(),
                    style: TextStyle(color: permColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(access.sharedToName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(access.sharedToEmail, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                _PermissionBadge(permission: access.permission),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              access.documentTitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.share_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('Chia sẻ bởi ${access.sharedByName} · ${fmt.format(access.sharedAt)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                if (!access.isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Đã thu hồi', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                ],
              ],
            ),
            if (access.isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showChangePermissionDialog(context),
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Đổi quyền', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => service.revokeAccess(access.id),
                      icon: const Icon(Icons.block_rounded, size: 14),
                      label: const Text('Thu hồi', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _permColor(SharePermission p) {
    switch (p) {
      case SharePermission.view: return Colors.blue;
      case SharePermission.comment: return Colors.orange;
      case SharePermission.edit: return const Color(0xFFD81B60);
    }
  }

  Future<void> _showChangePermissionDialog(BuildContext context) async {
    SharePermission? selected = access.permission;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thay đổi quyền truy cập', style: TextStyle(fontSize: 16)),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: SharePermission.values.map((p) => RadioListTile<SharePermission>(
              title: Text(p.displayName, style: const TextStyle(fontSize: 14)),
              value: p,
              groupValue: selected,
              onChanged: (v) => setState(() => selected = v),
              activeColor: const Color(0xFFD81B60),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD81B60)),
            onPressed: () {
              if (selected != null) service.updatePermission(access.id, selected!);
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

// ─────────── Dialog tạo yêu cầu mượn ───────────
class _BorrowRequestDialog extends StatefulWidget {
  final List<StudyDocument> documents;
  final BorrowShareService service;

  const _BorrowRequestDialog({required this.documents, required this.service});

  @override
  State<_BorrowRequestDialog> createState() => _BorrowRequestDialogState();
}

class _BorrowRequestDialogState extends State<_BorrowRequestDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  StudyDocument? _selectedDoc;
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.request_page_rounded, color: Color(0xFFD81B60)),
          SizedBox(width: 8),
          Text('Yêu cầu mượn tài liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn tài liệu *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 6),
              DropdownButtonFormField<StudyDocument>(
                value: _selectedDoc,
                hint: const Text('Chọn tài liệu...', style: TextStyle(fontSize: 13)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: widget.documents.map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: (v) => setState(() => _selectedDoc = v),
              ),
              const SizedBox(height: 14),
              _buildTextField(_nameCtrl, 'Tên người mượn *', Icons.person_rounded),
              const SizedBox(height: 10),
              _buildTextField(_emailCtrl, 'Email *', Icons.email_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField(_noteCtrl, 'Ghi chú', Icons.notes_rounded, maxLines: 2),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 14)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 16, color: Color(0xFFD81B60)),
                      const SizedBox(width: 8),
                      Text(
                        _dueDate == null ? 'Chọn ngày trả (tùy chọn)' : 'Hạn trả: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                        style: TextStyle(fontSize: 13, color: _dueDate == null ? Colors.grey : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD81B60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Gửi yêu cầu'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedDoc == null || _nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    await widget.service.createBorrowRequest(
      documentId: _selectedDoc!.id,
      documentTitle: _selectedDoc!.title,
      requesterName: _nameCtrl.text.trim(),
      requesterEmail: _emailCtrl.text.trim(),
      dueDate: _dueDate,
      note: _noteCtrl.text.trim(),
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã gửi yêu cầu mượn thành công!'), backgroundColor: Colors.green),
      );
    }
  }
}

// ─────────── Shared Access Dialog ───────────
class ShareDocumentDialog extends StatefulWidget {
  final StudyDocument document;
  const ShareDocumentDialog({super.key, required this.document});

  @override
  State<ShareDocumentDialog> createState() => _ShareDocumentDialogState();
}

class _ShareDocumentDialogState extends State<ShareDocumentDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  SharePermission _permission = SharePermission.view;
  DateTime? _expiresAt;
  bool _loading = false;
  final BorrowShareService _service = BorrowShareService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.share_rounded, color: Color(0xFFD81B60)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chia sẻ tài liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(widget.document.title, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameCtrl, 'Tên người nhận *', Icons.person_rounded),
              const SizedBox(height: 10),
              _buildTextField(_emailCtrl, 'Email người nhận *', Icons.email_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              const Text('Quyền truy cập', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 6),
              ...SharePermission.values.map((p) => _PermissionOption(
                permission: p,
                isSelected: _permission == p,
                onTap: () => setState(() => _permission = p),
              )),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _expiresAt = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded, size: 16, color: Color(0xFFD81B60)),
                      const SizedBox(width: 8),
                      Text(
                        _expiresAt == null ? 'Không giới hạn thời gian' : 'Hết hạn: ${DateFormat('dd/MM/yyyy').format(_expiresAt!)}',
                        style: TextStyle(fontSize: 13, color: _expiresAt == null ? Colors.grey : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD81B60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          icon: const Icon(Icons.share_rounded, size: 16),
          label: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Chia sẻ'),
          onPressed: _loading ? null : _submit,
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    await _service.shareDocument(
      documentId: widget.document.id,
      documentTitle: widget.document.title,
      sharedToName: _nameCtrl.text.trim(),
      sharedToEmail: _emailCtrl.text.trim(),
      permission: _permission,
      expiresAt: _expiresAt,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã chia sẻ tài liệu thành công!'), backgroundColor: Colors.green),
      );
    }
  }
}

// ─────────── Helper Widgets ───────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BorrowStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(status.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _color(BorrowStatus s) {
    switch (s) {
      case BorrowStatus.pending: return Colors.orange;
      case BorrowStatus.approved: return Colors.green;
      case BorrowStatus.rejected: return Colors.red;
      case BorrowStatus.returned: return Colors.blue;
      case BorrowStatus.cancelled: return Colors.grey;
    }
  }
}

class _PermissionBadge extends StatelessWidget {
  final SharePermission permission;
  const _PermissionBadge({required this.permission});

  @override
  Widget build(BuildContext context) {
    final color = _color(permission);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(permission.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _color(SharePermission p) {
    switch (p) {
      case SharePermission.view: return Colors.blue;
      case SharePermission.comment: return Colors.orange;
      case SharePermission.edit: return const Color(0xFFD81B60);
    }
  }
}

class _PermissionOption extends StatelessWidget {
  final SharePermission permission;
  final bool isSelected;
  final VoidCallback onTap;
  const _PermissionOption({required this.permission, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFD81B60) : Colors.grey.shade400;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7D8DF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFFD81B60) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(permission.displayName, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFFD81B60) : Colors.black87))),
          ],
        ),
      ),
    );
  }
}
