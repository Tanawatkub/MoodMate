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
  _FakeAuthService({this.userId = 'test-user'});

  final String? userId;

  @override
  String? get currentUserId => userId;

  @override
  String? get currentDisplayName => 'Test User';

  @override
  DateTime? get currentUserCreatedAt => null;

  @override
  Stream<String?> get userIdChanges => Stream.value(userId);

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
  _FakeDiaryRepository([List<MoodEntry>? initialEntries])
    : entries = initialEntries ?? [];

  final List<MoodEntry> entries;
  final List<String> updatedIds = [];
  final List<String> deletedIds = [];
  Exception? error;
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
    if (error != null) throw error!;
    createdCount++;
    final created = entry.copyWith(id: 'created-$createdCount');
    entries.add(created);
    return created;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    if (error != null) throw error!;
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
  tester.view.physicalSize = const Size(800, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
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
}

AppDependencies _dependencies({
  required _FakeDiaryRepository diary,
  String? userId = 'test-user',
}) => AppDependencies(
  auth: _FakeAuthService(userId: userId),
  diary: diary,
  reflection: _FakeReflectionService(),
);

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
  testWidgets('แสดงอารมณ์ 4 แบบ แท็ก 7 ตัว และปุ่มบันทึก', (tester) async {
    final diary = _FakeDiaryRepository();
    await _openCheckIn(tester, _dependencies(diary: diary));

    for (final label in ['มีความสุข', 'โกรธ', 'เศร้า', 'เฉยๆ']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(FilterChip), findsNWidgets(7));
    expect(find.text('บันทึกความรู้สึก'), findsOneWidget);
  });

  testWidgets('ยังไม่เลือกอารมณ์ -> แจ้งเตือนและไม่บันทึก', (tester) async {
    final diary = _FakeDiaryRepository();
    await _openCheckIn(tester, _dependencies(diary: diary));

    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pump();

    expect(find.text('กรุณาเลือกอารมณ์ก่อนบันทึก'), findsOneWidget);
    expect(diary.createdCount, 0);
  });

  testWidgets('ยังไม่ login -> แจ้งเซสชันหมดอายุและไม่บันทึก', (tester) async {
    final diary = _FakeDiaryRepository();
    await _openCheckIn(tester, _dependencies(diary: diary, userId: null));

    await tester.tap(find.text('เศร้า'));
    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pump();

    expect(find.textContaining('เซสชันหมดอายุ'), findsOneWidget);
    expect(diary.createdCount, 0);
  });

  testWidgets('เลือกอารมณ์+แท็ก+ข้อความ แล้วบันทึกสำเร็จ', (tester) async {
    final diary = _FakeDiaryRepository();
    MoodEntry? result;
    await _openCheckIn(tester, _dependencies(diary: diary));
    result = null;

    await tester.tap(find.text('เศร้า'));
    await tester.tap(find.text('แล็บ'));
    await tester.enterText(find.byType(TextFormField), 'งานเยอะมาก');
    await tester.pump();
    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(diary.createdCount, 1);
    final saved = diary.entries.single;
    expect(saved.userId, 'test-user');
    expect(saved.mood, 'sad');
    expect(saved.contextTags, ['Lab']);
    expect(saved.diaryText, 'งานเยอะมาก');
    expect(saved.id, 'created-1');
    expect(find.byType(NewCheckInScreen), findsNothing);
    result = saved;
    expect(result, isNotNull);
  });

  testWidgets('บันทึกล้มเหลว -> แจ้งข้อผิดพลาดและหน้ายังอยู่', (tester) async {
    final diary = _FakeDiaryRepository()..error = Exception('fail');
    await _openCheckIn(tester, _dependencies(diary: diary));

    await tester.tap(find.text('มีความสุข'));
    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(find.textContaining('บันทึกไม่สำเร็จ'), findsOneWidget);
    expect(find.byType(NewCheckInScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('บันทึกความรู้สึก'), findsOneWidget);
  });

  testWidgets('ตัวนับคำ', (tester) async {
    final diary = _FakeDiaryRepository();
    await _openCheckIn(tester, _dependencies(diary: diary));

    expect(find.text('0 คำ'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'สวัสดี ครับ');
    await tester.pump();
    expect(find.text('2 คำ'), findsOneWidget);
  });

  testWidgets('dialog หัวข้อช่วยคิด เปิดและปิดได้', (tester) async {
    final diary = _FakeDiaryRepository();
    await _openCheckIn(tester, _dependencies(diary: diary));

    await tester.tap(find.text('อยากได้หัวข้อช่วยคิด?'));
    await tester.pumpAndSettle();
    expect(find.text('หัวข้อช่วยคิด'), findsOneWidget);

    await tester.tap(find.text('เข้าใจแล้ว'));
    await tester.pumpAndSettle();
    expect(find.text('หัวข้อช่วยคิด'), findsNothing);
  });

  testWidgets('เลือกแท็กแล้วยกเลิก -> contextTags ว่าง', (tester) async {
    final diary = _FakeDiaryRepository();
    await _openCheckIn(tester, _dependencies(diary: diary));

    await tester.tap(find.text('แล็บ'));
    await tester.pump();
    await tester.tap(find.text('แล็บ'));
    await tester.pump();
    await tester.tap(find.text('โกรธ'));
    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(diary.entries.single.contextTags, isEmpty);
    expect(diary.entries.single.mood, 'angry');
  });

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

      await _openCheckIn(tester, _dependencies(diary: diary));
      await tester.tap(find.text('เศร้า'));
      await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
      await tester.tap(find.text('บันทึกความรู้สึก'));
      await tester.pumpAndSettle();

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
    final diary = _FakeDiaryRepository();

    await _openCheckIn(tester, _dependencies(diary: diary));
    await tester.tap(find.text('เศร้า'));
    await tester.ensureVisible(find.text('บันทึกความรู้สึก'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(diary.createdCount, 1);
    expect(diary.updatedIds, isEmpty);
    expect(diary.entries.single.mood, 'sad');
  });
}
