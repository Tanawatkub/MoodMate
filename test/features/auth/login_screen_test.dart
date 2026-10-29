import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/app_dependencies.dart';
import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/auth/login_screen.dart';
import 'package:moodmate/features/auth/signup_screen.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/diary_repository.dart';
import 'package:moodmate/services/mock_reflection_service.dart';

class _FakeAuth implements AuthService {
  String? uid;
  AuthException? signInError;
  AuthException? resetError;
  final signInCalls = <String>[];
  final resetCalls = <String>[];

  @override
  String? get currentUserId => uid;
  @override
  String? get currentDisplayName => 'Test';
  @override
  DateTime? get currentUserCreatedAt => null;
  @override
  Stream<String?> get userIdChanges => Stream.value(uid);

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls.add('$email|$password');
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signUp({required String email, required String password}) async {}
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    resetCalls.add(email);
    if (resetError != null) throw resetError!;
  }

  @override
  Future<void> signOut() async {}
  @override
  Future<void> updateDisplayName(String name) async {}
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
  var successCount = 0;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    successCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(
        dependencies: AppDependencies(
          auth: auth,
          diary: _FakeDiary(),
          reflection: const MockReflectionService(),
        ),
        onLoginSuccess: () => successCount++,
      ),
    ));
  }

  Future<void> fill(WidgetTester tester, String email, String pw) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'อีเมล'), email);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'รหัสผ่าน'), pw);
  }

  setUp(() => auth = _FakeAuth());

  testWidgets('ช่องว่าง -> แสดงข้อความตรวจสอบ ไม่เรียก signIn', (tester) async {
    await open(tester);
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pump();

    expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
    expect(auth.signInCalls, isEmpty);
  });

  testWidgets('login สำเร็จ -> เรียก onLoginSuccess', (tester) async {
    auth.uid = 'u1';
    await open(tester);
    await fill(tester, 'a@b.com', 'secret1');
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls, ['a@b.com|secret1']);
    expect(successCount, 1);
  });

  testWidgets('signIn ผิดพลาด -> แสดงข้อความ ไม่เรียก onLoginSuccess',
      (tester) async {
    auth.signInError =
        const AuthException('invalid-credential', 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    await open(tester);
    await fill(tester, 'a@b.com', 'wrong');
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    expect(find.text('อีเมลหรือรหัสผ่านไม่ถูกต้อง'), findsOneWidget);
    expect(successCount, 0);
  });

  testWidgets('signIn ผ่านแต่ไม่มี session -> แจ้ง session-not-ready',
      (tester) async {
    auth.uid = null;
    await open(tester);
    await fill(tester, 'a@b.com', 'secret1');
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('โหลดสถานะบัญชีไม่สำเร็จ'), findsOneWidget);
    expect(successCount, 0);
  });

  testWidgets('สลับแสดง/ซ่อนรหัสผ่าน', (tester) async {
    await open(tester);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('ลืมรหัสผ่าน: อีเมลว่าง -> แจ้งให้กรอกก่อน', (tester) async {
    await open(tester);
    await tester.tap(find.text('ลืมรหัสผ่าน?'));
    await tester.pump();

    expect(find.textContaining('กรอกอีเมลก่อน'), findsOneWidget);
    expect(auth.resetCalls, isEmpty);
  });

  testWidgets('ลืมรหัสผ่าน: สำเร็จ -> ส่งอีเมลและแจ้งผล', (tester) async {
    await open(tester);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'อีเมล'), ' a@b.com ');
    await tester.tap(find.text('ลืมรหัสผ่าน?'));
    await tester.pumpAndSettle();

    expect(auth.resetCalls, ['a@b.com']);
    expect(find.textContaining('ส่งลิงก์ตั้งรหัสผ่านใหม่'), findsOneWidget);
  });

  testWidgets('ลืมรหัสผ่าน: ผิดพลาด -> แสดงข้อความ error', (tester) async {
    auth.resetError =
        const AuthException('invalid-email', 'รูปแบบอีเมลไม่ถูกต้อง');
    await open(tester);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'อีเมล'), 'bad');
    await tester.tap(find.text('ลืมรหัสผ่าน?'));
    await tester.pumpAndSettle();

    expect(find.text('รูปแบบอีเมลไม่ถูกต้อง'), findsOneWidget);
  });

  testWidgets('กด "สมัครสมาชิก" -> ไปหน้า SignupScreen', (tester) async {
    await open(tester);
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);
  });
}