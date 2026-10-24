/// Interface กลางสำหรับบัญชีผู้ใช้ (Email/Password)
/// UI เรียกผ่าน interface นี้เท่านั้น ห้าม import Firebase ใน Widget
/// ห้ามเปลี่ยน signature โดยไม่คุยทีม
abstract class AuthService {
  /// UID ของผู้ใช้ที่ login อยู่ หรือ null ถ้ายังไม่ได้ login
  /// userId ของ MoodEntry ต้องมาจากค่านี้เท่านั้น
  String? get currentUserId;

  /// ส่งค่าใหม่ทุกครั้งที่สถานะ login เปลี่ยน (UID หรือ null เมื่อ logout)
  Stream<String?> get userIdChanges;

  /// สมัครสมาชิกแล้ว login ให้ทันที
  /// โยน [AuthException] เมื่อผิดพลาด
  Future<void> signUp({required String email, required String password});

  /// โยน [AuthException] เมื่อผิดพลาด
  Future<void> signIn({required String email, required String password});

  Future<void> signOut();
}

/// ข้อผิดพลาดด้านบัญชีที่ UI แสดงให้ผู้ใช้ได้เลย
class AuthException implements Exception {
  /// รหัสสั้น ๆ ไว้ให้โค้ดแยกแยะ เช่น 'email-already-in-use'
  final String code;

  /// ข้อความภาษาไทยสำหรับแสดงบน UI
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => message;
}