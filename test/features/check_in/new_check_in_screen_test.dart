import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/check_in/new_check_in_screen.dart';
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

class _FakeDiaryRepository implements DiaryRepository {
  _FakeDiaryRepository(this.entries);

  final List<MoodEntry> entries;
  final List<String> updatedIds = [];
  final List<String> deletedIds = [];
  var createdCount = 0;

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    return entries
        .where(
          (entry) =>
              entry.userId == userId &&
              (from == null || !entry.createdAt.isBefore(from)) &&
              (to == null || entry.createdAt.isBefore(to)),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async {
    createdCount++;
    final created = entry.copyWith(id: 'created-$createdCount');
    entries.add(created);
    return created;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    updatedIds.add(entry.id);
    final index = entries.indexWhere((candidate) => candidate.id == entry.id);
    entries[index] = entry;
    return entry;
  }

  @override
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
    deletedIds.add(entryId);
    entries.removeWhere(
      (entry) => entry.userId == userId && entry.id == entryId,
    );
  }
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

Future<void> _openCheckIn(
  WidgetTester tester,
  AppDependencies dependencies,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push<MoodEntry>(
              context,
              MaterialPageRoute<MoodEntry>(
                builder: (_) => NewCheckInScreen(dependencies: dependencies),
              ),
            ),
            child: const Text('เปิด'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('เปิด'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('เศร้า'));
  await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('บันทึกความรู้สึก'));
  await tester.pumpAndSettle();
}

MoodEntry _entry(String id, DateTime createdAt) => MoodEntry(
  id: id,
  userId: 'test-user',
  mood: 'happy',
  contextTags: const [],
  diaryText: 'ข้อความเดิม',
  createdAt: createdAt,
  updatedAt: createdAt,
);

void main() {
  testWidgets(
    'saving again today updates the latest entry and removes duplicates',
    (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final olderToday = _entry(
        'older-today',
        today.add(const Duration(hours: 1)),
      );
      final latestToday = _entry(
        'latest-today',
        today.add(const Duration(hours: 2)),
      );
      final yesterday = _entry(
        'yesterday',
        today.subtract(const Duration(days: 1)),
      );
      final diary = _FakeDiaryRepository([olderToday, latestToday, yesterday]);
      final dependencies = AppDependencies(
        auth: _FakeAuthService(),
        diary: diary,
        reflection: _FakeReflectionService(),
      );

      await _openCheckIn(tester, dependencies);

      expect(diary.createdCount, 0);
      expect(diary.updatedIds, ['latest-today']);
      expect(diary.deletedIds, ['older-today']);
      final saved = diary.entries.singleWhere(
        (entry) => entry.id == 'latest-today',
      );
      expect(saved.mood, 'sad');
      expect(saved.createdAt, latestToday.createdAt);
      expect(diary.entries.any((entry) => entry.id == 'yesterday'), isTrue);
    },
  );

  testWidgets('first check-in of the day creates a new entry', (tester) async {
    final diary = _FakeDiaryRepository([]);
    final dependencies = AppDependencies(
      auth: _FakeAuthService(),
      diary: diary,
      reflection: _FakeReflectionService(),
    );

    await _openCheckIn(tester, dependencies);

    expect(diary.createdCount, 1);
    expect(diary.updatedIds, isEmpty);
    expect(diary.entries.single.mood, 'sad');
  });
}
