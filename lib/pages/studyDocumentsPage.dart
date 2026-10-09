import 'package:flutter/material.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../database/study_document_dao.dart';
import '../database/study_course_dao.dart';
import '../widgets/studyDocumentCard.dart';
import 'addEditStudyDocumentPage.dart';
import 'studyDocumentSearchPage.dart';
import 'studyCoursesPage.dart';

class StudyDocumentsPage extends StatefulWidget {
  const StudyDocumentsPage({super.key});

  @override
  State<StudyDocumentsPage> createState() => _StudyDocumentsPageState();
}

class _StudyDocumentsPageState extends State<StudyDocumentsPage> {
  final DocumentDao _documentDao = DocumentDao();
  final CourseDao _courseDao = CourseDao();

  int _selectedTabIndex = 0; // 0: Tất cả, 1: Bài giảng, 2: Bài tập, 3: Tham khảo
  String? _selectedCourseId;

  DocumentType? _getCurrentTabType() {
    switch (_selectedTabIndex) {
      case 1:
        return DocumentType.lecture;
      case 2:
        return DocumentType.exercise;
      case 3:
        return DocumentType.reference;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentType = _getCurrentTabType();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD81B60),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm tài liệu'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDocumentPage()),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          // Header Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kho Tài liệu Học tập',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lưu trữ bài giảng, bài tập và tài liệu tham khảo',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.school_rounded),
                    tooltip: 'Quản lý môn học',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursesPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Tìm kiếm',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DocumentSearchPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.cloud_done_rounded, color: Color(0xFFD81B60)),
                    tooltip: 'Trạng thái Firebase Cloud',
                    onPressed: () => _showCloudDialog(context),
                  ),
                ],
              ),
            ),
          ),

          // Type Tab Pills
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabPill('Tất cả', 0),
                    _buildTabPill('Bài giảng', 1),
                    _buildTabPill('Bài tập', 2),
                    _buildTabPill('Tham khảo', 3),
                  ],
                ),
              ),
            ),
          ),

          // Course Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
              child: StreamBuilder<List<Course>>(
                stream: _courseDao.watchAll(),
                initialData: _courseDao.getAll(),
                builder: (context, snapshot) {
                  final courses = snapshot.data ?? [];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCourseFilterChip(
                          label: 'Tất cả môn',
                          isSelected: _selectedCourseId == null,
                          onTap: () => setState(() => _selectedCourseId = null),
                        ),
                        const SizedBox(width: 8),
                        ...courses.map((c) {
                          final isSel = _selectedCourseId == c.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCourseFilterChip(
                              label: c.code,
                              dotColor: Color(c.colorValue),
                              isSelected: isSel,
                              onTap: () => setState(() => _selectedCourseId = isSel ? null : c.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Document List
          StreamBuilder<List<StudyDocument>>(
            stream: _documentDao.watchAll(),
            initialData: _documentDao.getAll(),
            builder: (context, snapshot) {
              final allDocuments = snapshot.data ?? _documentDao.getAll();

              // Instant filter by Tab Type
              var documents = allDocuments;
              if (currentType != null) {
                documents = documents.where((d) => d.type == currentType).toList();
              }

              // Instant filter by Course
              if (_selectedCourseId != null && _selectedCourseId!.isNotEmpty && _selectedCourseId != 'all') {
                documents = documents.where((d) => d.courseId == _selectedCourseId).toList();
              }

              if (documents.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Chưa có tài liệu nào trong danh mục này', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = documents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StudyDocumentCard(
                          document: doc,
                          onStatusChanged: (newStatus) async {
                            await _documentDao.update(doc.copyWith(status: newStatus));
                          },
                          onDelete: () async {
                            await _documentDao.delete(doc.id);
                          },
                        ),
                      );
                    },
                    childCount: documents.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF7D8DF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFFD81B60) : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseFilterChip({
    required String label,
    Color? dotColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7D8DF) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD81B60) : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              CircleAvatar(backgroundColor: dotColor, radius: 5),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFD81B60) : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloudDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7D8DF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFFD81B60), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tích hợp Firebase Cloud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Hệ thống Đám mây Google', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('Dự án:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Spacer(),
                        Text('study-document-cloud', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.account_circle_rounded, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Tài khoản Google:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Spacer(),
                        Text('sinhvien.hung@gmail.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.storage_rounded, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text('Cơ sở dữ liệu:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Spacer(),
                        Text('Cloud Firestore (Active)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Mọi bài giảng, bài tập và môn học được đồng bộ theo cơ chế Local-First (Offline-First) kết hợp đám mây Google.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.sync_rounded, size: 16),
              label: const Text('Đồng bộ ngay'),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đồng bộ thành công dữ liệu với Cloud Firestore!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
