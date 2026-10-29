import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/auth/signup_screen.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/diary_repository.dart';
import 'package:moodmate/services/mock_reflection_service.dart';

class _FakeAuth implements AuthService {
  AuthException? signUpError;
  final signUpCalls = <String>[];
  final names = <String>[];

  @override
  String? get currentUserId => 'u1';
  @override
  String? get currentDisplayName => 'Test';
  @override
  DateTime? get currentUserCreatedAt => null;
  @override
  Stream<String?> get userIdChanges => Stream.value('u1');
  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalls.add('$email|$password');
    if (signUpError != null) throw signUpError!;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> updateDisplayName(String name) async => names.add(name);
}

class _FakeDiary implements DiaryRepository {
  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async => entry;
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
  late _FakeAuth auth;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final deps = AppDependencies(
      auth: auth,
      diary: _FakeDiary(),
      reflection: const MockReflectionService(),
    );
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => SignupScreen(dependencies: deps)),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> fill(
    WidgetTester tester, {
    String name = 'สมชาย',
    String email = 'a@b.com',
    String pw = 'secret1',
    String confirm = 'secret1',
  }) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'ชื่อผู้ใช้งาน'), name);
    await tester.enterText(find.widgetWithText(TextFormField, 'อีเมล'), email);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'รหัสผ่าน (อย่างน้อย 6 ตัวอักษร)'),
        pw);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'ยืนยันรหัสผ่าน'), confirm);
  }

  setUp(() => auth = _FakeAuth());

  testWidgets('ช่องว่าง -> แสดงข้อความตรวจสอบ ไม่เรียก signUp', (tester) async {
    await open(tester);
    await tester.tap(find.text('สมัครสมาชิก').first);
    await tester.pump();

    expect(find.text('กรุณากรอกชื่อผู้ใช้งาน'), findsOneWidget);
    expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
    expect(find.text('กรุณายืนยันรหัสผ่าน'), findsOneWidget);
    expect(auth.signUpCalls, isEmpty);
  });

  testWidgets('อีเมลไม่มี @ -> รูปแบบไม่ถูกต้อง', (tester) async {
    await open(tester);
    await fill(tester, email: 'abc');
    await tester.tap(find.text('สมัครสมาชิก').first);
    await tester.pump();

    expect(find.text('รูปแบบอีเมลไม่ถูกต้อง'), findsOneWidget);
    expect(auth.signUpCalls, isEmpty);
  });

  testWidgets('รหัสผ่านสั้นกว่า 6 -> ไม่ผ่าน', (tester) async {
    await open(tester);
    await fill(tester, pw: '123', confirm: '123');
    await tester.tap(find.text('สมัครสมาชิก').first);
    await tester.pump();

    expect(find.text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'), findsOneWidget);
    expect(auth.signUpCalls, isEmpty);
  });

  testWidgets('รหัสผ่านไม่ตรงกัน -> ไม่ผ่าน', (tester) async {
    await open(tester);
    await fill(tester, confirm: 'different');
    await tester.tap(find.text('สมัครสมาชิก').first);
    await tester.pump();

    expect(find.text('รหัสผ่านไม่ตรงกัน'), findsOneWidget);
    expect(auth.signUpCalls, isEmpty);
  });

  testWidgets('ข้อมูลถูกต้อง -> signUp + ตั้งชื่อ + กลับหน้าแรก', (tester) async {
    await open(tester);
    await fill(tester);
    await tester.tap(find.text('สมัครสมาชิก').first);
    await tester.pumpAndSettle();

    expect(auth.signUpCalls, ['a@b.com|secret1']);
    expect(auth.names, ['สมชาย']);
    expect(find.byType(SignupScreen), findsNothing);
  });

  testWidgets('signUp ผิดพลาด -> แสดงข้อความ หน้ายังอยู่', (tester) async {
    auth.signUpError =
        const AuthException('email-already-in-use', 'อีเมลนี้ถูกใช้สมัครแล้ว');
    await open(tester);
    await fill(tester);
    await tester.tap(find.text('สมัครสมาชิก').first);
    await tester.pumpAndSettle();

    expect(find.text('อีเมลนี้ถูกใช้สมัครแล้ว'), findsOneWidget);
    expect(find.byType(SignupScreen), findsOneWidget);
    expect(auth.names, isEmpty);
  });

  testWidgets('สลับแสดง/ซ่อนรหัสผ่านทั้งสองช่อง', (tester) async {
    await open(tester);
    final icons = find.byIcon(Icons.visibility_off_outlined);
    expect(icons, findsNWidgets(2));
    await tester.tap(icons.first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
  });

  testWidgets('ปุ่มย้อนกลับและลิงก์ "เข้าสู่ระบบ" ปิดหน้า', (tester) async {
    await open(tester);
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsNothing);

    await open(tester);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsNothing);
  });
}