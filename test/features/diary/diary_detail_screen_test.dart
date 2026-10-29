import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/diary/diary_detail_screen.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/diary_repository.dart';
import 'package:moodmate/services/mock_reflection_service.dart';

class _FakeAuth implements AuthService {
  _FakeAuth(this.uid);
  final String? uid;

  @override
  String? get currentUserId => uid;
  @override
  String? get currentDisplayName => 'Test';
  @override
  DateTime? get currentUserCreatedAt => null;
  @override
  Stream<String?> get userIdChanges => Stream.value(uid);
  @override
  Future<void> signIn({required String email, required String password}) async {}
  @override
  Future<void> signUp({required String email, required String password}) async {}
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> updateDisplayName(String name) async {}
}

class _FakeDiary implements DiaryRepository {
  final deleted = <String>[];
  Exception? deleteError;

  @override
  Future<void> deleteEntry(
      {required String userId, required String entryId}) async {
    if (deleteError != null) throw deleteError!;
    deleted.add(entryId);
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async => entry;
  @override
  Future<List<MoodEntry>> getEntries(
          {required String userId, DateTime? from, DateTime? to}) async =>
      [];
  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async => entry;
}

MoodEntry _entry({
  String mood = 'sad',
  List<String> tags = const ['Lab', 'Deadline'],
  String text = 'งานเยอะมาก',
  String userId = 'u1',
}) {
  final t = DateTime(2026, 10, 25, 9, 5);
  return MoodEntry(
    id: 'e1',
    userId: userId,
    mood: mood,
    contextTags: tags,
    diaryText: text,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  late _FakeDiary diary;
  bool? popResult;

  Future<void> open(
    WidgetTester tester,
    MoodEntry entry, {
    String? uid = 'u1',
  }) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final deps = AppDependencies(
      auth: _FakeAuth(uid),
      diary: diary,
      reflection: const MockReflectionService(),
    );
    popResult = null;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                popResult = await Navigator.push<bool>(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) =>
                        DiaryDetailScreen(dependencies: deps, entry: entry),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  setUp(() => diary = _FakeDiary());

  testWidgets('แสดงวันที่ เวลา อารมณ์ แท็ก และข้อความ', (tester) async {
    await open(tester, _entry());

    expect(find.text('25 ต.ค. 2026'), findsOneWidget);
    expect(find.text('09:05 น.'), findsOneWidget);
    expect(find.text('เศร้า'), findsOneWidget);
    expect(find.text('Lab'), findsOneWidget);
    expect(find.text('Deadline'), findsOneWidget);
    expect(find.text('งานเยอะมาก'), findsOneWidget);
  });

  testWidgets('ข้อความว่าง -> แสดงข้อความแทน และไม่มีแท็ก', (tester) async {
    await open(tester, _entry(text: '', tags: const []));

    expect(find.text('ไม่มีข้อความบันทึก'), findsOneWidget);
    expect(find.byType(Chip), findsNothing);
  });

   for (final m in ['happy', 'angry', 'sad', 'neutral', 'unknown']) {
    testWidgets('แสดงไอคอนอารมณ์ ($m)', (tester) async {
      await open(tester, _entry(mood: m));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  }

  testWidgets('ลบ: กดยกเลิก -> ไม่ลบ', (tester) async {
    await open(tester, _entry());

    await tester.tap(find.byTooltip('ลบบันทึก'));
    await tester.pumpAndSettle();
    expect(find.text('ลบบันทึกนี้หรือไม่?'), findsOneWidget);

    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();

    expect(diary.deleted, isEmpty);
    expect(find.byType(DiaryDetailScreen), findsOneWidget);
  });

  testWidgets('ลบ: ยืนยัน -> เรียก deleteEntry และ pop true', (tester) async {
    await open(tester, _entry());

    await tester.tap(find.byTooltip('ลบบันทึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();

    expect(diary.deleted, ['e1']);
    expect(popResult, isTrue);
    expect(find.byType(DiaryDetailScreen), findsNothing);
  });

  testWidgets('ลบ: userId ไม่ตรงเจ้าของ -> แจ้งไม่มีสิทธิ์', (tester) async {
    await open(tester, _entry(userId: 'other'));

    await tester.tap(find.byTooltip('ลบบันทึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();

    expect(find.text('ไม่พบสิทธิ์สำหรับลบบันทึกนี้'), findsOneWidget);
    expect(diary.deleted, isEmpty);
  });

  testWidgets('ลบ: ยังไม่ login -> แจ้งไม่มีสิทธิ์', (tester) async {
    await open(tester, _entry(), uid: null);

    await tester.tap(find.byTooltip('ลบบันทึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();

    expect(find.text('ไม่พบสิทธิ์สำหรับลบบันทึกนี้'), findsOneWidget);
    expect(diary.deleted, isEmpty);
  });

  testWidgets('ลบล้มเหลว -> แจ้งข้อผิดพลาด หน้ายังอยู่', (tester) async {
    diary.deleteError = Exception('fail');
    await open(tester, _entry());

    await tester.tap(find.byTooltip('ลบบันทึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ลบบันทึกไม่สำเร็จ'), findsOneWidget);
    expect(find.byType(DiaryDetailScreen), findsOneWidget);
  });

  testWidgets('AI: กดยกเลิกในหน้ายินยอม -> ไม่เปิดหน้า reflection',
      (tester) async {
    await open(tester, _entry());

    await tester.tap(find.text('สะท้อนความรู้สึกด้วย MoodMate'));
    await tester.pumpAndSettle();
    expect(find.text('ส่งบันทึกไปให้ AI สะท้อนความรู้สึก?'), findsOneWidget);

    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();

    expect(find.text('ส่งบันทึกไปให้ AI สะท้อนความรู้สึก?'), findsNothing);
    expect(find.byType(DiaryDetailScreen), findsOneWidget);
  });

  testWidgets('AI: กดดำเนินการต่อ -> ออกจากหน้ายินยอมและเปิดหน้าใหม่',
      (tester) async {
    await open(tester, _entry());

    await tester.tap(find.text('สะท้อนความรู้สึกด้วย MoodMate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ดำเนินการต่อ'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ส่งบันทึกไปให้ AI สะท้อนความรู้สึก?'), findsNothing);
  });
}