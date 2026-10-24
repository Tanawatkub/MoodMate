/// ช่วงหนึ่งสัปดาห์แบบ [start, end)
///
/// ข้อตกลงชั่วคราว (รอทีมยืนยัน): สัปดาห์เริ่มวันจันทร์ 00:00 ตามเวลาท้องถิ่นของเครื่อง
class WeekRange {
  final DateTime start;
  final DateTime end;

  const WeekRange({required this.start, required this.end});

  factory WeekRange.containing(DateTime date) {
    final local = date.toLocal();
    final daysSinceMonday = local.weekday - DateTime.monday;
    final start = DateTime(local.year, local.month, local.day - daysSinceMonday);
    final end = DateTime(start.year, start.month, start.day + 7);
    return WeekRange(start: start, end: end);
  }
}