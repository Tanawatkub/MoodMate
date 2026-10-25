import '../../models/weekly_insight.dart';
import '../../repositories/diary_repository.dart';
import 'week_range.dart';
import 'weekly_insight_calculator.dart';

/// ตัวเชื่อม: DiaryRepository -> WeeklyInsightCalculator -> WeeklyInsight
/// ไม่ import Firebase ใช้ได้ทั้ง MockDiaryRepository และ FirestoreDiaryRepository
class WeeklyInsightLoader {
  WeeklyInsightLoader({
    required this.repository,
    required this.userId,
    WeeklyInsightCalculator? calculator,
    DateTime Function()? now,
  })  : calculator = calculator ?? WeeklyInsightCalculator(),
        now = now ?? DateTime.now;

  final DiaryRepository repository;

  /// UID ของผู้ใช้ที่ login (จาก AuthService.currentUserId)
  final String userId;
  final WeeklyInsightCalculator calculator;
  final DateTime Function() now;

  Future<WeeklyInsight> load() async {
    final week = WeekRange.last7Days(now());
    final entries = await repository.getEntries(
      userId: userId,
      from: week.start,
      to: week.end,
    );
    return calculator.calculate(
      entries: entries,
      weekStart: week.start,
      weekEnd: week.end,
    );
  }
}