import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/check_in/new_check_in_screen.dart';
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
  final created = <MoodEntry>[];
  Exception? error;

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async {
    if (error != null) throw error!;
    created.add(entry);
    return entry;
  }

  @override
  Future<List<MoodEntry>> getEntries(
          {required String userId, DateTime? from, DateTime? to}) async =>
      [];
  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async => entry;
  @override
  Future<void> deleteEntry(
      {required String userId, required String entryId}) async {}
}

void main() {
  late _FakeDiary diary;
  bool? result;

  Future<void> openScreen(WidgetTester tester, {String? uid = 'u1'}) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final deps = AppDependencies(
      auth: _FakeAuth(uid),
      diary: diary,
      reflection: const MockReflectionService(),
    );
    result = null;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<bool>(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => NewCheckInScreen(dependencies: deps),
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

  testWidgets('แสดงอารมณ์ 4 แบบ แท็ก 7 ตัว และปุ่มบันทึก', (tester) async {
    await openScreen(tester);

    for (final label in ['มีความสุข', 'โกรธ', 'เศร้า', 'เฉยๆ']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(FilterChip), findsNWidgets(7));
    expect(find.text('บันทึกความรู้สึก'), findsOneWidget);
  });

  testWidgets('ยังไม่เลือกอารมณ์ -> แจ้งเตือนและไม่บันทึก', (tester) async {
    await openScreen(tester);

    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pump();

    expect(find.text('กรุณาเลือกอารมณ์ก่อนบันทึก'), findsOneWidget);
    expect(diary.created, isEmpty);
  });

  testWidgets('ยังไม่ login -> แจ้งเซสชันหมดอายุและไม่บันทึก', (tester) async {
    await openScreen(tester, uid: null);

    await tester.tap(find.text('เศร้า'));
    await tester.pump();
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pump();

    expect(find.textContaining('เซสชันหมดอายุ'), findsOneWidget);
    expect(diary.created, isEmpty);
  });

  testWidgets('เลือกอารมณ์+แท็ก+ข้อความ แล้วบันทึกสำเร็จ', (tester) async {
    await openScreen(tester);

    await tester.tap(find.text('เศร้า'));
    await tester.tap(find.text('แล็บ'));
    await tester.enterText(find.byType(TextFormField), 'งานเยอะมาก');
    await tester.pump();
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(diary.created, hasLength(1));
    final e = diary.created.single;
    expect(e.userId, 'u1');
    expect(e.mood, 'sad');
    expect(e.contextTags, ['Lab']);
    expect(e.diaryText, 'งานเยอะมาก');
    expect(result, isTrue);
    expect(find.byType(NewCheckInScreen), findsNothing);
  });

  testWidgets('บันทึกล้มเหลว -> แจ้งข้อผิดพลาด หน้ายังอยู่ ปุ่มกดได้อีก',
      (tester) async {
    diary.error = Exception('fail');
    await openScreen(tester);

    await tester.tap(find.text('มีความสุข'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(find.textContaining('บันทึกไม่สำเร็จ'), findsOneWidget);
    expect(find.byType(NewCheckInScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('บันทึกความรู้สึก'), findsOneWidget);
  });

  testWidgets('ตัวนับคำ', (tester) async {
    await openScreen(tester);

    expect(find.text('0 คำ'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'สวัสดี ครับ');
    await tester.pump();
    expect(find.text('2 คำ'), findsOneWidget);
  });

  testWidgets('dialog หัวข้อช่วยคิด เปิดและปิดได้', (tester) async {
    await openScreen(tester);

    await tester.tap(find.text('อยากได้หัวข้อช่วยคิด?'));
    await tester.pumpAndSettle();
    expect(find.text('หัวข้อช่วยคิด'), findsOneWidget);

    await tester.tap(find.text('เข้าใจแล้ว'));
    await tester.pumpAndSettle();
    expect(find.text('หัวข้อช่วยคิด'), findsNothing);
  });

  testWidgets('เลือกแท็กแล้วยกเลิก -> contextTags ว่าง', (tester) async {
    await openScreen(tester);

    await tester.tap(find.text('แล็บ'));
    await tester.pump();
    await tester.tap(find.text('แล็บ'));
    await tester.pump();
    await tester.tap(find.text('โกรธ'));
    await tester.tap(find.text('บันทึกความรู้สึก'));
    await tester.pumpAndSettle();

    expect(diary.created.single.contextTags, isEmpty);
    expect(diary.created.single.mood, 'angry');
  });
}