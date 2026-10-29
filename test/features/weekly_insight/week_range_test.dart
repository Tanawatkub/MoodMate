import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/week_range.dart';

void main() {
  test('วันพุธ ได้สัปดาห์ที่เริ่มวันจันทร์ก่อนหน้า', () {
    final w = WeekRange.containing(DateTime(2026, 10, 21, 15, 30));
    expect(w.start, DateTime(2026, 10, 19));
    expect(w.end, DateTime(2026, 10, 26));
  });

  test('วันจันทร์ 00:00 เป็นต้นสัปดาห์ของตัวเอง', () {
    final w = WeekRange.containing(DateTime(2026, 10, 19));
    expect(w.start, DateTime(2026, 10, 19));
    expect(w.end, DateTime(2026, 10, 26));
  });

  test('วันอาทิตย์ 23:59 ยังอยู่สัปดาห์เดิม', () {
    final w = WeekRange.containing(DateTime(2026, 10, 25, 23, 59));
    expect(w.start, DateTime(2026, 10, 19));
    expect(w.end, DateTime(2026, 10, 26));
  });

  test('วันจันทร์ถัดไป เริ่มสัปดาห์ใหม่', () {
    final w = WeekRange.containing(DateTime(2026, 10, 26));
    expect(w.start, DateTime(2026, 10, 26));
    expect(w.end, DateTime(2026, 11, 2));
  });

  test('ข้ามเดือนและข้ามปีได้ถูกต้อง', () {
    final month = WeekRange.containing(DateTime(2026, 11, 1)); // อาทิตย์
    expect(month.start, DateTime(2026, 10, 26));
    expect(month.end, DateTime(2026, 11, 2));

    final year = WeekRange.containing(DateTime(2026, 1, 1)); // พฤหัสบดี
    expect(year.start, DateTime(2025, 12, 29));
    expect(year.end, DateTime(2026, 1, 5));
  });
}