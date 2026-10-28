/// ช่วงเวลาแบบ [start, end) คือรวมต้น ไม่รวมปลาย
class WeekRange {
  final DateTime start;
  final DateTime end;

  const WeekRange({required this.start, required this.end});

  /// 7 วันล่าสุด: วันนี้ + 6 วันก่อนหน้า (ตามข้อตกลงใน data-contracts.md หัวข้อ 12.2)
  /// ใช้เวลาท้องถิ่นของเครื่อง ขอบเขตคงที่ตลอดวัน ไม่เลื่อนตามเวลาที่เปิดแอป
  factory WeekRange.last7Days(DateTime now) {
    final local = now.toLocal();
    final start = DateTime(local.year, local.month, local.day - 6);
    final end = DateTime(local.year, local.month, local.day + 1);
    return WeekRange(start: start, end: end);
  }

  /// สัปดาห์จันทร์-อาทิตย์ (เก็บไว้เผื่อทีมเปลี่ยนใจ ตอนนี้ Dashboard ไม่ได้ใช้)
  factory WeekRange.containing(DateTime date) {
    final local = date.toLocal();
    final daysSinceMonday = local.weekday - DateTime.monday;
    final start = DateTime(local.year, local.month, local.day - daysSinceMonday);
    final end = DateTime(start.year, start.month, start.day + 7);
    return WeekRange(start: start, end: end);
  }
}