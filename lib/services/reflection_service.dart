import '../models/reflection_result.dart';
import '../models/weekly_insight.dart';

abstract class ReflectionService {
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  });

  Future<String> summarizeInsight({required WeeklyInsight insight});
}

class InsightSummaryException implements Exception {
  const InsightSummaryException(this.message);

  final String message;

  @override
  String toString() => message;
}
