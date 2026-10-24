class MoodEntry {
  final String id;
  final String userId;
  final String mood;
  final List<String> contextTags;
  final String diaryText;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.contextTags,
    required this.diaryText,
    required this.createdAt,
    required this.updatedAt,
  });
}