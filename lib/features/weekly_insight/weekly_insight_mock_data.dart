import '../../models/mood_entry.dart';
import '../../models/weekly_insight.dart';
import 'weekly_insight_calculator.dart';

WeeklyInsight buildMockWeeklyInsight() {
  final weekStart = DateTime(2026, 10, 19);
  final weekEnd = DateTime(2026, 10, 26);

  MoodEntry entry(String id, String mood, List<String> tags, int day) {
    final time = DateTime(2026, 10, day, 20);
    return MoodEntry(
      id: id,
      userId: 'mock-user',
      mood: mood,
      contextTags: tags,
      diaryText: 'ข้อความตัวอย่าง',
      createdAt: time,
      updatedAt: time,
    );
  }

  final entries = [
    entry('1', 'neutral', ['Coding'], 19),
    entry('2', 'sad', ['Lab', 'Deadline'], 20),
    entry('3', 'sad', ['Project', 'Deadline'], 21),
    entry('4', 'happy', ['Group Work'], 22),
    entry('5', 'angry', ['Presentation', 'Deadline'], 23),
    entry('6', 'happy', ['Personal'], 24),
  ];

  return WeeklyInsightCalculator().calculate(
    entries: entries,
    weekStart: weekStart,
    weekEnd: weekEnd,
  );
}