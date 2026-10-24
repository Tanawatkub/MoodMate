import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

/// ตัวจริงที่ใช้ Firebase Authentication (Email/Password)
/// ห้าม log อีเมลหรือรหัสผ่าน
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> get userIdChanges =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _toAuthException(e);
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _toAuthException(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthException _toAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthException('invalid-email', 'รูปแบบอีเมลไม่ถูกต้อง');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // ข้อความเดียวกัน ไม่บอกว่าผิดที่อีเมลหรือรหัสผ่าน
        return const AuthException(
            'invalid-credential', 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      case 'email-already-in-use':
        return const AuthException(
            'email-already-in-use', 'อีเมลนี้ถูกใช้สมัครแล้ว');
      case 'weak-password':
        return const AuthException(
            'weak-password', 'รหัสผ่านสั้นเกินไป (อย่างน้อย 6 ตัวอักษร)');
      case 'user-disabled':
        return const AuthException('user-disabled', 'บัญชีนี้ถูกระงับการใช้งาน');
      case 'too-many-requests':
        return const AuthException(
            'too-many-requests', 'ลองหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่');
      case 'network-request-failed':
        return const AuthException(
            'network-request-failed', 'เชื่อมต่ออินเทอร์เน็ตไม่ได้');
      case 'operation-not-allowed':
        return const AuthException('operation-not-allowed',
            'ยังไม่ได้เปิดการเข้าสู่ระบบด้วยอีเมลในระบบ');
      default:
        return AuthException(e.code, 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }
}