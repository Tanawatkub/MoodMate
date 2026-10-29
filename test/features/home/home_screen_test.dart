import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/home/home_screen.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/models/reflection_result.dart';
import 'package:moodmate/models/weekly_insight.dart';
import 'package:moodmate/repositories/diary_repository.dart';
import 'package:moodmate/services/reflection_service.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService(this.currentUserCreatedAt);

  @override
  final DateTime? currentUserCreatedAt;

  @override
  String? get currentUserId => 'test-user';

  @override
  String? get currentDisplayName => 'Test User';

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

class _FakeDiaryRepository implements DiaryRepository {
  String? userId;
  DateTime? from;
  DateTime? to;

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    this.userId = userId;
    this.from = from;
    this.to = to;
    return [];
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) => throw UnimplementedError();

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) => throw UnimplementedError();

  @override
  Future<void> deleteEntry({required String userId, required String entryId}) =>
      throw UnimplementedError();
}

class _FakeReflectionService implements ReflectionService {
  @override
  Future<String> summarizeInsight({required WeeklyInsight insight}) async => '';

  @override
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('new account history starts on signup day', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final signupDate = DateTime(now.year, now.month, now.day - 2, 14);
    final diary = _FakeDiaryRepository();
    final dependencies = AppDependencies(
      auth: _FakeAuthService(signupDate),
      diary: diary,
      reflection: _FakeReflectionService(),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(dependencies: dependencies)),
    );
    await tester.pumpAndSettle();

    expect(find.text('ตั้งแต่สมัครสมาชิก'), findsOneWidget);
    final calendar = tester.widget<GridView>(
      find.byKey(const ValueKey('history-calendar')),
    );
    expect(
      (calendar.childrenDelegate as SliverChildBuilderDelegate).childCount,
      3,
    );
    expect(diary.userId, 'test-user');
    expect(diary.from, DateTime(now.year, now.month, now.day - 2));
    expect(diary.to, DateTime(now.year, now.month, now.day + 1));
  });
}
