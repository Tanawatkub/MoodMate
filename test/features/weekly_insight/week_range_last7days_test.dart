import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/week_range.dart';

void main() {
  test('7 วันล่าสุด = วันนี้ + 6 วันก่อนหน้า ถึงเที่ยงคืนพรุ่งนี้ (ไม่รวม)', () {
    final w = WeekRange.last7Days(DateTime(2026, 10, 25, 15, 30));
    expect(w.start, DateTime(2026, 10, 19));
    expect(w.end, DateTime(2026, 10, 26));
  });

  test('ขอบเขตคงที่ตลอดวัน ไม่เลื่อนตามเวลาที่เปิดแอป', () {
    final morning = WeekRange.last7Days(DateTime(2026, 10, 25, 0, 0));
    final night = WeekRange.last7Days(DateTime(2026, 10, 25, 23, 59));
    expect(morning.start, night.start);
    expect(morning.end, night.end);
  });

  test('ข้ามเดือนได้ถูกต้อง', () {
    final w = WeekRange.last7Days(DateTime(2026, 11, 2, 10));
    expect(w.start, DateTime(2026, 10, 27));
    expect(w.end, DateTime(2026, 11, 3));
  });

  test('ข้ามปีได้ถูกต้อง', () {
    final w = WeekRange.last7Days(DateTime(2026, 1, 3, 10));
    expect(w.start, DateTime(2025, 12, 28));
    expect(w.end, DateTime(2026, 1, 4));
  });
}