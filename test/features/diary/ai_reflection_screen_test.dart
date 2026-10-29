import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/diary/ai_reflection_screen.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/models/reflection_result.dart';
import 'package:moodmate/models/weekly_insight.dart';
import 'package:moodmate/repositories/diary_repository.dart';
import 'package:moodmate/services/reflection_service.dart';

class _FakeAuthService implements AuthService {
  @override
  String? get currentUserId => 'test-user';

  @override
  String? get currentDisplayName => 'Test User';

  @override
  DateTime? get currentUserCreatedAt => null;

  @override
  Stream<String?> get userIdChanges => Stream.value(currentUserId);

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String name) async {}
}

class _UnusedDiaryRepository implements DiaryRepository {
  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async => [];

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) => throw UnimplementedError();

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) => throw UnimplementedError();

  @override
  Future<void> deleteEntry({required String userId, required String entryId}) =>
      throw UnimplementedError();
}

class _FakeReflectionService implements ReflectionService {
  _FakeReflectionService(this.source);

  final ReflectionSource source;

  @override
  Future<String> summarizeInsight({required WeeklyInsight insight}) async => '';

  @override
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  }) async => ReflectionResult(reflectionText: 'ข้อความทดสอบ', source: source);
}

void main() {
  for (final source in ReflectionSource.values) {
    testWidgets('labels reflection source as $source', (tester) async {
      final dependencies = AppDependencies(
        auth: _FakeAuthService(),
        diary: _UnusedDiaryRepository(),
        reflection: _FakeReflectionService(source),
      );
      final now = DateTime(2026, 10, 29, 12);
      final entry = MoodEntry(
        id: 'entry-1',
        userId: 'test-user',
        mood: 'sad',
        contextTags: const [],
        diaryText: 'ข้อความบันทึก',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AiReflectionScreen(dependencies: dependencies, entry: entry),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ข้อความทดสอบ'), findsOneWidget);
      expect(
        find.text(
          source == ReflectionSource.gemini
              ? 'สร้างโดย Gemini AI'
              : 'ข้อความสำรองจาก MoodMate • ไม่ได้มาจาก Gemini',
        ),
        findsOneWidget,
      );
    });
  }
}
