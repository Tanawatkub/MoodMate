import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/diary/diary_detail_screen.dart';
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
  final List<MoodEntry> entries = [];
  String? userId;
  DateTime? from;
  DateTime? to;
  int loadCount = 0;
  int _nextId = 0;

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    loadCount++;
    this.userId = userId;
    this.from = from;
    this.to = to;
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
    final saved = entry.copyWith(id: 'entry-${_nextId++}');
    entries.add(saved);
    return saved;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    final index = entries.indexWhere((candidate) => candidate.id == entry.id);
    entries[index] = entry;
    return entry;
  }

  @override
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
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

  testWidgets('new check-in updates home immediately with the selected mood', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final signupDate = DateTime(now.year, now.month, now.day);
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
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('เศร้า'));
    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(diary.entries, hasLength(1));
    expect(diary.entries.single.mood, 'sad');
    expect(diary.loadCount, 2);
    expect(
      find.text('บันทึก 1 ครั้ง • อารมณ์ที่พบบ่อย: เศร้า'),
      findsOneWidget,
    );

    final calendar = find.byKey(const ValueKey('history-calendar'));
    final moodIcon = tester.widget<Icon>(
      find.descendant(
        of: calendar,
        matching: find.byIcon(Icons.sentiment_dissatisfied),
      ),
    );
    expect(moodIcon.color, const Color(0xFF333333));
    final avatar = tester.widget<CircleAvatar>(
      find.descendant(of: calendar, matching: find.byType(CircleAvatar)),
    );
    expect(avatar.backgroundColor, const Color(0xFFE2ECF5));
  });

  testWidgets('deleting today entry removes its mood from home immediately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = MoodEntry(
      id: 'today-entry',
      userId: 'test-user',
      mood: 'sad',
      contextTags: const [],
      diaryText: 'ทดสอบลบ',
      createdAt: now,
      updatedAt: now,
    );
    final diary = _FakeDiaryRepository()..entries.add(entry);
    final dependencies = AppDependencies(
      auth: _FakeAuthService(today),
      diary: diary,
      reflection: _FakeReflectionService(),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(dependencies: dependencies)),
    );
    await tester.pumpAndSettle();

    final calendar = find.byKey(const ValueKey('history-calendar'));
    await tester.tap(
      find.descendant(
        of: calendar,
        matching: find.byIcon(Icons.sentiment_dissatisfied),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DiaryDetailScreen), findsOneWidget);
    final detailAvatar = tester.widget<CircleAvatar>(
      find.descendant(
        of: find.byType(DiaryDetailScreen),
        matching: find.byType(CircleAvatar),
      ),
    );
    expect(detailAvatar.backgroundColor, const Color(0xFFE2ECF5));
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: find.byType(DiaryDetailScreen),
              matching: find.byIcon(Icons.sentiment_dissatisfied),
            ),
          )
          .color,
      const Color(0xFF333333),
    );

    await tester.tap(find.byTooltip('ลบบันทึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ').last);
    await tester.pumpAndSettle();

    expect(diary.entries, isEmpty);
    expect(find.byType(DiaryDetailScreen), findsNothing);
    expect(
      find.descendant(
        of: calendar,
        matching: find.byIcon(Icons.sentiment_dissatisfied),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: calendar, matching: find.byIcon(Icons.remove)),
      findsOneWidget,
    );
  });
}
