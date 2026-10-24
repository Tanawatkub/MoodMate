import '../../models/mood_entry.dart';
import '../../models/weekly_insight.dart';
import 'weekly_insight_config.dart';

class WeeklyInsightCalculator {
  /// นับช่วง [weekStart, weekEnd) คือรวมเวลาเริ่ม แต่ไม่รวมเวลาสิ้นสุด
  ///
  /// Validation:
  /// - mood ที่ไม่อยู่ในรายการกลาง: ข้ามทั้งรายการ (ไม่นับใน totalEntries)
  ///   ทำให้ผลรวมของ moodCounts เท่ากับ totalEntries เสมอ
  /// - tag ที่ไม่อยู่ในรายการกลาง: เมินเฉพาะ tag นั้น รายการยังถูกนับ
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

      if (!weeklyInsightMoods.contains(entry.mood)) continue;

      total++;
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;

      // tag แต่ละตัวนับหนึ่งครั้งต่อรายการ
      for (final tag in entry.contextTags.toSet()) {
        if (!weeklyInsightContextTags.contains(tag)) continue;
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