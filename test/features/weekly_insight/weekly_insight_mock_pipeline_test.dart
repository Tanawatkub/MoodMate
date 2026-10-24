import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/week_range.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_calculator.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_mock_data.dart';
import 'package:moodmate/models/weekly_insight.dart';

void main() {
  final calculator = WeeklyInsightCalculator();
  final entries = buildMockEntries();

  WeeklyInsight weekOf(DateTime date) {
    final week = WeekRange.containing(date);
    return calculator.calculate(
      entries: entries,
      weekStart: week.start,
      weekEnd: week.end,
    );
  }

  test('สัปดาห์ 19-25 ต.ค. ได้ผลตรงกับที่คำนวณด้วยมือ', () {
    final r = weekOf(DateTime(2026, 10, 21));

    expect(r.weekStart, DateTime(2026, 10, 19));
    expect(r.weekEnd, DateTime(2026, 10, 26));
    expect(r.totalEntries, 6);
    expect(r.moodCounts, {'happy': 2, 'sad': 2, 'angry': 1, 'neutral': 1});
    expect(r.contextCounts, {
      'Coding': 1,
      'Lab': 1,
      'Project': 1,
      'Group Work': 1,
      'Presentation': 1,
      'Deadline': 3,
      'Personal': 1,
    });
  });

  test('mood และ tag ที่ไม่รู้จัก ไม่ปนเข้าผลสรุป', () {
    final r = weekOf(DateTime(2026, 10, 21));

    expect(r.moodCounts.containsKey('excited'), isFalse);
    expect(r.contextCounts.containsKey('Gaming'), isFalse);
  });

  test('สัปดาห์ก่อนหน้าและถัดไป นับเฉพาะรายการของตัวเอง', () {
    final before = weekOf(DateTime(2026, 10, 14));
    expect(before.totalEntries, 2);
    expect(before.moodCounts, {'sad': 1, 'happy': 1});
    expect(before.contextCounts, {'Lab': 1, 'Personal': 1});

    final after = weekOf(DateTime(2026, 10, 27));
    expect(after.totalEntries, 1);
    expect(after.moodCounts, {'angry': 1});
    expect(after.contextCounts, {'Deadline': 1});
  });

  test('รายการที่ถูกต้องทุกอันถูกนับในสัปดาห์ใดสัปดาห์หนึ่งเพียงครั้งเดียว', () {
    final total = weekOf(DateTime(2026, 10, 14)).totalEntries +
        weekOf(DateTime(2026, 10, 21)).totalEntries +
        weekOf(DateTime(2026, 10, 27)).totalEntries;

    // ข้อมูล 10 รายการ มี 1 รายการ mood ผิดปกติถูกข้าม
    expect(entries.length, 10);
    expect(total, 9);
  });
}