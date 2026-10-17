import '../struct/studyDocument.dart';
import '../struct/userPreferences.dart';

/// Kết quả gợi ý tài liệu với điểm số
class RecommendationResult {
  final StudyDocument document;
  final double score;
  final List<String> reasons;

  const RecommendationResult({
    required this.document,
    required this.score,
    required this.reasons,
  });
}

/// Thuật toán Recommendation Engine dựa trên:
/// 1. Tag-based Similarity (Jaccard Similarity)
/// 2. User Preference Scoring (View history, tag frequency)
/// 3. Course affinity
/// 4. Recency boost (tài liệu mới ưu tiên hơn)
/// 5. Status boost (tài liệu chưa đọc ưu tiên)
class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final UserPreferences _prefs = UserPreferences();

  UserPreferences get preferences => _prefs;

  /// Ghi nhận người dùng xem tài liệu
  void recordDocumentView(StudyDocument doc) {
    _prefs.recordView(doc.id, doc.tags, doc.courseId, doc.type.name);
  }

  /// Ghi nhận người dùng tương tác với tag
  void recordTagClick(String tag) {
    _prefs.recordTagInteraction(tag);
  }

  /// Tính điểm Jaccard Similarity giữa hai tập tags
  double _jaccardSimilarity(List<String> tagsA, List<String> tagsB) {
    if (tagsA.isEmpty && tagsB.isEmpty) return 0.5;
    if (tagsA.isEmpty || tagsB.isEmpty) return 0.0;
    final setA = Set<String>.from(tagsA.map((t) => t.toLowerCase()));
    final setB = Set<String>.from(tagsB.map((t) => t.toLowerCase()));
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Tính điểm dựa trên tag preferences của người dùng
  double _tagPreferenceScore(List<String> docTags) {
    if (docTags.isEmpty || _prefs.tagScores.isEmpty) return 0.0;
    double score = 0.0;
    int maxPossible = 0;
    for (final tag in docTags) {
      final tagLower = tag.toLowerCase();
      final tagScore = _prefs.tagScores.entries
          .where((e) => e.key.toLowerCase() == tagLower)
          .fold(0, (sum, e) => sum + e.value);
      score += tagScore;
      maxPossible += (_prefs.tagScores.values.isEmpty ? 1 : _prefs.tagScores.values.reduce((a, b) => a > b ? a : b));
    }
    if (maxPossible == 0) return 0.0;
    return (score / maxPossible).clamp(0.0, 1.0);
  }

  /// Tính điểm dựa trên course affinity
  double _courseAffinityScore(String courseId) {
    if (_prefs.courseScores.isEmpty) return 0.0;
    final total = _prefs.courseScores.values.fold(0, (a, b) => a + b);
    if (total == 0) return 0.0;
    return (((_prefs.courseScores[courseId] ?? 0) / total) * 2).clamp(0.0, 1.0);
  }

  /// Recency boost: tài liệu được cập nhật gần đây có điểm cao hơn
  double _recencyScore(DateTime updatedAt) {
    final daysDiff = DateTime.now().difference(updatedAt).inDays;
    if (daysDiff <= 1) return 1.0;
    if (daysDiff <= 7) return 0.8;
    if (daysDiff <= 30) return 0.5;
    if (daysDiff <= 90) return 0.3;
    return 0.1;
  }

  /// Status boost: Ưu tiên tài liệu todo và inProgress hơn completed
  double _statusBoost(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.todo:
        return 1.0;
      case DocumentStatus.inProgress:
        return 0.8;
      case DocumentStatus.completed:
        return 0.2;
    }
  }

  /// Tạo danh sách lý do gợi ý
  List<String> _buildReasons(
    StudyDocument doc,
    double tagPrefScore,
    double courseScore,
    double jaccardScore,
    UserPreferences prefs,
  ) {
    final reasons = <String>[];
    if (tagPrefScore > 0.3) {
      final matchedTags = doc.tags
          .where((t) => (prefs.tagScores[t] ?? 0) > 0)
          .take(2)
          .toList();
      if (matchedTags.isNotEmpty) {
        reasons.add('Tag yêu thích: ${matchedTags.join(", ")}');
      }
    }
    if (courseScore > 0.2) {
      reasons.add('Môn học thường xem');
    }
    if (jaccardScore > 0.3) {
      reasons.add('Nội dung tương tự đã xem');
    }
    if (doc.isPinned) {
      reasons.add('Tài liệu được ghim');
    }
    if (doc.status == DocumentStatus.todo) {
      reasons.add('Chưa được học');
    }
    if (reasons.isEmpty) reasons.add('Gợi ý cho bạn');
    return reasons;
  }

  /// === MAIN: Tính toán và trả về danh sách tài liệu gợi ý ===
  List<RecommendationResult> recommend(
    List<StudyDocument> allDocuments, {
    int topK = 10,
    String? excludeDocId,
  }) {
    final candidates = allDocuments
        .where((d) => d.id != excludeDocId)
        .toList();

    if (candidates.isEmpty) return [];

    // Xác định "profile" user hiện tại từ prefs
    final userTopTags = _prefs.topTags;

    final results = candidates.map((doc) {
      double totalScore = 0.0;

      // 1. Tag preference score (weight: 0.35)
      final tagPrefScore = _tagPreferenceScore(doc.tags);
      totalScore += tagPrefScore * 0.35;

      // 2. Jaccard similarity với top tags user (weight: 0.25)
      final jaccardScore = _jaccardSimilarity(doc.tags, userTopTags);
      totalScore += jaccardScore * 0.25;

      // 3. Course affinity (weight: 0.20)
      final courseScore = _courseAffinityScore(doc.courseId);
      totalScore += courseScore * 0.20;

      // 4. Recency score (weight: 0.10)
      totalScore += _recencyScore(doc.updatedAt) * 0.10;

      // 5. Status boost (weight: 0.10)
      totalScore += _statusBoost(doc.status) * 0.10;

      // Bonus: pinned documents
      if (doc.isPinned) totalScore = (totalScore * 1.1).clamp(0.0, 1.0);

      // Penalty: already viewed many times
      final viewCount = _prefs.viewHistory[doc.id] ?? 0;
      if (viewCount > 5) totalScore *= 0.85;

      final reasons = _buildReasons(doc, tagPrefScore, courseScore, jaccardScore, _prefs);

      return RecommendationResult(
        document: doc,
        score: totalScore,
        reasons: reasons,
      );
    }).toList();

    // Sort by score desc
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(topK).toList();
  }

  /// Gợi ý tài liệu tương tự (content-based filtering)
  List<RecommendationResult> findSimilar(
    StudyDocument target,
    List<StudyDocument> allDocuments, {
    int topK = 5,
  }) {
    final candidates = allDocuments.where((d) => d.id != target.id).toList();

    final results = candidates.map((doc) {
      double score = 0.0;

      // Tag similarity (weight: 0.5)
      score += _jaccardSimilarity(doc.tags, target.tags) * 0.5;

      // Same course (weight: 0.3)
      if (doc.courseId == target.courseId) score += 0.3;

      // Same type (weight: 0.2)
      if (doc.type == target.type) score += 0.2;

      final reasons = <String>[];
      if (doc.courseId == target.courseId) reasons.add('Cùng môn học');
      if (doc.type == target.type) reasons.add('Cùng loại tài liệu');
      final commonTags = doc.tags.where((t) => target.tags.contains(t)).toList();
      if (commonTags.isNotEmpty) reasons.add('Tag chung: ${commonTags.take(2).join(", ")}');
      if (reasons.isEmpty) reasons.add('Liên quan');

      return RecommendationResult(document: doc, score: score, reasons: reasons);
    }).toList();

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(topK).where((r) => r.score > 0).toList();
  }
}
