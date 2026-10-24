import '../../models/mood_entry.dart';
import '../../models/weekly_insight.dart';

class WeeklyInsightCalculator {
  /// นับช่วง [weekStart, weekEnd) คือรวมเวลาเริ่ม แต่ไม่รวมเวลาสิ้นสุด
  WeeklyInsight calculate({
    required List<MoodEntry> entries,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    final moodCounts = <String, int>{};
    final contextCounts = <String, int>{};
    var total = 0;

    for (final entry in entries) {
      final inRange = !entry.createdAt.isBefore(weekStart) &&
          entry.createdAt.isBefore(weekEnd);
      if (!inRange) continue;

      total++;
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;

      // tag แต่ละตัวนับหนึ่งครั้งต่อรายการ
      for (final tag in entry.contextTags.toSet()) {
        contextCounts[tag] = (contextCounts[tag] ?? 0) + 1;
      }
    }

    return WeeklyInsight(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalEntries: total,
      moodCounts: moodCounts,
      contextCounts: contextCounts,
    );
  }
}