/// Interface กลางสำหรับบัญชีผู้ใช้ (Email/Password)
/// UI เรียกผ่าน interface นี้เท่านั้น ห้าม import Firebase ใน Widget
/// ห้ามเปลี่ยน signature โดยไม่คุยทีม
abstract class AuthService {
  /// UID ของผู้ใช้ที่ login อยู่ หรือ null ถ้ายังไม่ได้ login
  /// userId ของ MoodEntry ต้องมาจากค่านี้เท่านั้น
  String? get currentUserId;

  /// ส่งค่าใหม่ทุกครั้งที่สถานะ login เปลี่ยน (UID หรือ null เมื่อ logout)
  Stream<String?> get userIdChanges;

  /// ชื่อที่แสดงของผู้ใช้ที่ login อยู่ (เก็บกับบัญชีใน Firebase Authentication)
  /// null = ยังไม่ได้ตั้ง ให้ UI ใช้ชื่อเริ่มต้นเอง เช่น "ผู้ใช้งาน MoodMate"
  String? get currentDisplayName;

  /// วันและเวลาที่บัญชีปัจจุบันถูกสร้าง ใช้ null เมื่อไม่มี metadata
  DateTime? get currentUserCreatedAt;

  /// สมัครสมาชิกแล้ว login ให้ทันที
  /// โยน [AuthException] เมื่อผิดพลาด
  Future<void> signUp({required String email, required String password});

  /// โยน [AuthException] เมื่อผิดพลาด
  Future<void> signIn({required String email, required String password});

  /// ส่งลิงก์ตั้งรหัสผ่านใหม่ไปยังอีเมล
  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();

  /// ตั้ง/แก้ชื่อที่แสดง ตัดช่องว่างหัวท้ายก่อนบันทึก
  /// ชื่อต้องไม่ว่างและไม่เกิน [maxDisplayNameLength] ตัวอักษร (ข้อเสนอ ทีมยืนยันได้)
  /// โยน [AuthException] เมื่อผิดพลาด เช่น code 'invalid-display-name', 'not-signed-in'
  /// ชื่อเก็บถาวรกับบัญชี ไม่หายเมื่อปิดแอปหรือเปลี่ยนเครื่อง
  Future<void> updateDisplayName(String name);

  static const int maxDisplayNameLength = 50;
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
