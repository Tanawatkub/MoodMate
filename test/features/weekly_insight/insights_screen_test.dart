import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/weekly_insight/insights_screen.dart';
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
  DateTime? get currentUserCreatedAt => DateTime.now();

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
  _FakeDiaryRepository(this.entries);

  final List<MoodEntry> entries;
  int loadCount = 0;

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    loadCount++;
    return entries
        .where(
          (entry) =>
              (from == null || !entry.createdAt.isBefore(from)) &&
              (to == null || entry.createdAt.isBefore(to)),
        )
        .toList();
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
  int summaryCount = 0;

  @override
  Future<String> summarizeInsight({required WeeklyInsight insight}) async {
    summaryCount++;
    return 'อารมณ์ยิ้มเป็นอารมณ์ที่พบมากที่สุด';
  }

  @override
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('loads aggregate summary automatically and on range change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final diary = _FakeDiaryRepository([
      for (var day = 0; day < 3; day++)
        MoodEntry(
          id: 'entry-$day',
          userId: 'test-user',
          mood: day == 2 ? 'sad' : 'happy',
          contextTags: const ['Project'],
          diaryText: 'ข้อความส่วนตัวที่ไม่ควรส่งไปสร้างสรุป',
          createdAt: now.subtract(Duration(days: day)),
          updatedAt: now.subtract(Duration(days: day)),
        ),
    ]);
    final reflection = _FakeReflectionService();
    final dependencies = AppDependencies(
      auth: _FakeAuthService(),
      diary: diary,
      reflection: reflection,
    );

    await tester.pumpWidget(
      MaterialApp(home: InsightsScreen(dependencies: dependencies)),
    );
    await tester.pumpAndSettle();

    expect(reflection.summaryCount, 1);
    expect(find.text('บทสรุปจาก AI'), findsOneWidget);
    expect(find.text('อารมณ์ยิ้มเป็นอารมณ์ที่พบมากที่สุด'), findsOneWidget);
    expect(find.text('ปัจจัยหลัก'), findsOneWidget);

    await tester.tap(find.byTooltip('เลือกช่วงเวลา'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 วันที่ผ่านมา'));
    await tester.pumpAndSettle();

    expect(diary.loadCount, 2);
    expect(reflection.summaryCount, 2);
  });
}
