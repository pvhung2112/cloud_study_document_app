import 'package:flutter/material.dart';
import '../struct/studyDocument.dart';
import '../services/recommendationService.dart';
import '../database/study_document_dao.dart';
import '../database/study_course_dao.dart';
import '../struct/studyCourse.dart';
import 'addEditStudyDocumentPage.dart';

/// Trang gợi ý tài liệu dựa trên Recommendation Engine
class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final DocumentDao _docDao = DocumentDao();
  final CourseDao _courseDao = CourseDao();
  final RecommendationService _rec = RecommendationService();

  String? _selectedTag;

  // Simulate initial seeding preferences for demo
  @override
  void initState() {
    super.initState();
    _seedDemoPreferences();
  }

  void _seedDemoPreferences() {
    final prefs = _rec.preferences;
    if (prefs.tagScores.isEmpty) {
      _rec.recordTagClick('Flutter');
      _rec.recordTagClick('Flutter');
      _rec.recordTagClick('Slide');
      _rec.recordTagClick('KTPM');
      _rec.recordTagClick('Cashew');
      final docs = _docDao.getAll();
      if (docs.isNotEmpty) {
        _rec.recordDocumentView(docs.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: StreamBuilder<List<StudyDocument>>(
        stream: _docDao.watchAll(),
        initialData: _docDao.getAll(),
        builder: (context, snapshot) {
          final allDocs = snapshot.data ?? [];
          final recommendations = _rec.recommend(allDocs, topK: 10);
          final topTags = _rec.preferences.topTags;
          final courses = _courseDao.getAll();

          return CustomScrollView(
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
                                Text('Gợi ý cho bạn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                Text('Dựa trên sở thích và lịch sử của bạn', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFD81B60), Color(0xFFE91E63)]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preference Profile
                      _PreferenceProfileCard(preferences: _rec.preferences, courses: courses),
                      const SizedBox(height: 16),

                      // Top Tag Filters
                      if (topTags.isNotEmpty) ...[
                        const Text('Lọc theo sở thích', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildTagChip('Tất cả', null),
                              const SizedBox(width: 8),
                              ...topTags.map((t) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildTagChip(t, t),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),

              // Algorithm explanation
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _AlgorithmInfoCard(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recommendation Results Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Tài liệu gợi ý (${recommendations.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Làm mới', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),

              // Recommendation Cards
              if (recommendations.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.recommend_rounded, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('Chưa có đủ dữ liệu để gợi ý', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Hãy xem và tương tác thêm với tài liệu để hệ thống học sở thích của bạn', style: TextStyle(color: Colors.grey.shade400, fontSize: 12), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final result = recommendations[i];
                        final doc = result.document;

                        // Apply tag filter
                        if (_selectedTag != null && !doc.tags.contains(_selectedTag)) {
                          return const SizedBox.shrink();
                        }

                        final course = _courseDao.getAll().where((c) => c.id == doc.courseId).firstOrNull;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecommendationCard(
                            result: result,
                            course: course,
                            rank: i + 1,
                            onTap: () {
                              _rec.recordDocumentView(doc);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditDocumentPage(document: doc)));
                            },
                          ),
                        );
                      },
                      childCount: recommendations.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTagChip(String label, String? tag) {
    final isSelected = _selectedTag == tag;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() => _selectedTag = tag);
        if (tag != null) _rec.recordTagClick(tag);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD81B60) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFD81B60) : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFD81B60).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.local_offer_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _PreferenceProfileCard extends StatelessWidget {
  final dynamic preferences;
  final List<Course> courses;

  const _PreferenceProfileCard({required this.preferences, required this.courses});

  @override
  Widget build(BuildContext context) {
    final topTags = preferences.topTags.take(3).toList();
    final topCourse = preferences.topCourse;
    final course = courses.where((c) => c.id == topCourse).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7D8DF), Color(0xFFFCECF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD81B60).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_rounded, color: Color(0xFFD81B60), size: 18),
              SizedBox(width: 6),
              Text('Hồ sơ sở thích của bạn', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
            ],
          ),
          const SizedBox(height: 10),
          if (topTags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                const Text('Tags yêu thích:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ...topTags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD81B60).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD81B60))),
                )),
              ],
            ),
          ],
          if (course != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Môn học chính:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Color(course.colorValue).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(course.code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(course.colorValue))),
                ),
              ],
            ),
          ],
          if (topTags.isEmpty && course == null) ...[
            const Text('Chưa có dữ liệu sở thích. Hãy xem thêm tài liệu!', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

class _AlgorithmInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thuật toán Recommendation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                const SizedBox(height: 4),
                Text(
                  'Kết hợp: Jaccard Similarity (tags) · Course affinity · Lịch sử xem · Recency boost · Status priority',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationResult result;
  final Course? course;
  final int rank;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.result,
    required this.course,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final doc = result.document;
    final theme = Theme.of(context);
    final scorePercent = (result.score * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rank <= 3 ? const Color(0xFFD81B60).withOpacity(0.3) : theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _rankColor(rank).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _rankColor(rank)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (course != null) ...[
                          const SizedBox(height: 2),
                          Text(course!.code, style: TextStyle(fontSize: 11, color: Color(course!.colorValue), fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score indicator
                  Column(
                    children: [
                      Text('$scorePercent%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
                      const Text('phù hợp', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              // Score progress bar
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.score,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(_rankColor(rank)),
                  minHeight: 4,
                ),
              ),

              // Tags
              if (doc.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: doc.tags.take(4).map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('#$t', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  )).toList(),
                ),
              ],

              // Reasons
              if (result.reasons.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: result.reasons.map((r) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D8DF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 10, color: Color(0xFFD81B60)),
                        const SizedBox(width: 3),
                        Text(r, style: const TextStyle(fontSize: 10, color: Color(0xFFD81B60), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFB300); // Gold
    if (rank == 2) return const Color(0xFF90A4AE); // Silver
    if (rank == 3) return const Color(0xFFBF8C5C); // Bronze
    return const Color(0xFFD81B60);
  }
}
