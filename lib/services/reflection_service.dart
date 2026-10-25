import '../models/reflection_result.dart';

abstract class ReflectionService {
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  });
}
