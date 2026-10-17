import 'dart:convert';

/// Theo dõi hành vi và sở thích người dùng cho hệ thống gợi ý
class UserPreferences {
  /// Tag frequency map: tag -> số lần tương tác
  final Map<String, int> tagScores;

  /// Document view history: docId -> số lần xem
  final Map<String, int> viewHistory;

  /// Course interaction scores
  final Map<String, int> courseScores;

  /// Favorite document types (lecture/exercise/reference)
  final Map<String, int> typeScores;

  UserPreferences({
    Map<String, int>? tagScores,
    Map<String, int>? viewHistory,
    Map<String, int>? courseScores,
    Map<String, int>? typeScores,
  })  : tagScores = tagScores ?? {},
        viewHistory = viewHistory ?? {},
        courseScores = courseScores ?? {},
        typeScores = typeScores ?? {};

  UserPreferences copyWith({
    Map<String, int>? tagScores,
    Map<String, int>? viewHistory,
    Map<String, int>? courseScores,
    Map<String, int>? typeScores,
  }) {
    return UserPreferences(
      tagScores: tagScores ?? Map.from(this.tagScores),
      viewHistory: viewHistory ?? Map.from(this.viewHistory),
      courseScores: courseScores ?? Map.from(this.courseScores),
      typeScores: typeScores ?? Map.from(this.typeScores),
    );
  }

  void recordView(String docId, List<String> tags, String courseId, String docType) {
    viewHistory[docId] = (viewHistory[docId] ?? 0) + 1;
    courseScores[courseId] = (courseScores[courseId] ?? 0) + 1;
    typeScores[docType] = (typeScores[docType] ?? 0) + 1;
    for (final tag in tags) {
      tagScores[tag] = (tagScores[tag] ?? 0) + 2;
    }
  }

  void recordTagInteraction(String tag) {
    tagScores[tag] = (tagScores[tag] ?? 0) + 1;
  }

  /// Top N tags theo score
  List<String> get topTags {
    final sorted = tagScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(10).map((e) => e.key).toList();
  }

  /// Top course id
  String? get topCourse {
    if (courseScores.isEmpty) return null;
    return courseScores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Map<String, dynamic> toMap() => {
        'tag_scores': jsonEncode(tagScores),
        'view_history': jsonEncode(viewHistory),
        'course_scores': jsonEncode(courseScores),
        'type_scores': jsonEncode(typeScores),
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    Map<String, int> decodeMap(String key) {
      try {
        final raw = jsonDecode(map[key] as String? ?? '{}') as Map<String, dynamic>;
        return raw.map((k, v) => MapEntry(k, v as int));
      } catch (_) {
        return {};
      }
    }

    return UserPreferences(
      tagScores: decodeMap('tag_scores'),
      viewHistory: decodeMap('view_history'),
      courseScores: decodeMap('course_scores'),
      typeScores: decodeMap('type_scores'),
    );
  }
}
