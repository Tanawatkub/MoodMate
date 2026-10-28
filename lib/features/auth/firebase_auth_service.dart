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
  String? get currentDisplayName {
    final name = _auth.currentUser?.displayName;
    return (name == null || name.isEmpty) ? null : name;
  }

  @override
  DateTime? get currentUserCreatedAt =>
      _auth.currentUser?.metadata.creationTime?.toLocal();

  @override
  Future<void> signUp({required String email, required String password}) async {
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
  Future<void> signIn({required String email, required String password}) async {
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
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _toAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _toAuthException(e);
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('not-signed-in', 'ยังไม่ได้เข้าสู่ระบบ');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('invalid-display-name', 'กรุณากรอกชื่อ');
    }
    if (trimmed.runes.length > AuthService.maxDisplayNameLength) {
      throw const AuthException(
        'invalid-display-name',
        'ชื่อยาวเกินไป (ไม่เกิน ${AuthService.maxDisplayNameLength} ตัวอักษร)',
      );
    }
    try {
      await user.updateDisplayName(trimmed);
      await user.reload(); // ให้ currentUser สะท้อนชื่อใหม่ทันที
    } on FirebaseAuthException catch (e) {
      throw _toAuthException(e);
    }
  }

  AuthException _toAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthException('invalid-email', 'รูปแบบอีเมลไม่ถูกต้อง');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // ข้อความเดียวกัน ไม่บอกว่าผิดที่อีเมลหรือรหัสผ่าน
        return const AuthException(
          'invalid-credential',
          'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
        );
      case 'email-already-in-use':
        return const AuthException(
          'email-already-in-use',
          'อีเมลนี้ถูกใช้สมัครแล้ว',
        );
      case 'weak-password':
        return const AuthException(
          'weak-password',
          'รหัสผ่านสั้นเกินไป (อย่างน้อย 6 ตัวอักษร)',
        );
      case 'user-disabled':
        return const AuthException(
          'user-disabled',
          'บัญชีนี้ถูกระงับการใช้งาน',
        );
      case 'too-many-requests':
        return const AuthException(
          'too-many-requests',
          'ลองหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่',
        );
      case 'network-request-failed':
        return const AuthException(
          'network-request-failed',
          'เชื่อมต่ออินเทอร์เน็ตไม่ได้',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'operation-not-allowed',
          'ยังไม่ได้เปิดการเข้าสู่ระบบด้วยอีเมลในระบบ',
        );
      default:
        return AuthException(e.code, 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }
}
