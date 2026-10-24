import '../../models/mood_entry.dart';
import '../../models/weekly_insight.dart';
import 'week_range.dart';
import 'weekly_insight_calculator.dart';

List<MoodEntry> buildMockEntries() {
  MoodEntry entry(String id, String mood, List<String> tags, DateTime time) {
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

  return [
    // สัปดาห์ก่อนหน้า (12-18 ต.ค.)
    entry('p1', 'sad', ['Lab'], DateTime(2026, 10, 13, 20)),
    entry('p2', 'happy', ['Personal'], DateTime(2026, 10, 18, 22)),

    // สัปดาห์ 19-25 ต.ค. (ถูกนับ 6 รายการ)
    entry('1', 'neutral', ['Coding'], DateTime(2026, 10, 19, 20)),
    entry('2', 'sad', ['Lab', 'Deadline'], DateTime(2026, 10, 20, 20)),
    entry('3', 'sad', ['Project', 'Deadline'], DateTime(2026, 10, 21, 20)),
    // 'Gaming' ไม่อยู่ในรายการกลาง: tag ถูกเมิน แต่รายการนี้ยังถูกนับ
    entry('4', 'happy', ['Group Work', 'Gaming'], DateTime(2026, 10, 22, 20)),
    entry('5', 'angry', ['Presentation', 'Deadline'], DateTime(2026, 10, 23, 20)),
    entry('6', 'happy', ['Personal'], DateTime(2026, 10, 24, 20)),
    // 'excited' ไม่อยู่ในรายการกลาง: ถูกข้ามทั้งรายการ
    entry('x1', 'excited', ['Coding'], DateTime(2026, 10, 22, 9)),

    // สัปดาห์ถัดไป (เริ่ม 26 ต.ค.)
    entry('n1', 'angry', ['Deadline'], DateTime(2026, 10, 26, 8)),
  ];
}

/// สรุปของสัปดาห์ 19-25 ต.ค. 2026 จากข้อมูลตัวอย่าง
WeeklyInsight buildMockWeeklyInsight() {
  final week = WeekRange.containing(DateTime(2026, 10, 21));
  return WeeklyInsightCalculator().calculate(
    entries: buildMockEntries(),
    weekStart: week.start,
    weekEnd: week.end,
  );
}