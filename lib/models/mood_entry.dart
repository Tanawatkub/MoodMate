/// หนึ่งรายการบันทึก (mood + context tags + diary)
/// ห้ามเปลี่ยนชื่อ field โดยไม่คุยทีม
/// Model นี้ไม่ผูกกับ Firebase: การแปลง Firestore Timestamp <-> DateTime
/// ทำใน repository เท่านั้น
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

  MoodEntry copyWith({
    String? id,
    String? userId,
    String? mood,
    List<String>? contextTags,
    String? diaryText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      contextTags: contextTags ?? this.contextTags,
      diaryText: diaryText ?? this.diaryText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}