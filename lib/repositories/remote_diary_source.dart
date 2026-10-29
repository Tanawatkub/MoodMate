import '../models/mood_entry.dart';

/// ฝั่งเซิร์ฟเวอร์ที่ SyncedDiaryRepository ใช้ซิงก์ (ตัวจริงคือ FirestoreDiaryRepository)
/// แยกเป็น interface เพื่อให้ทดสอบตรรกะซิงก์ได้โดยไม่ต้องต่อ Firebase
abstract class RemoteDiarySource {
  /// อ่านรายการทั้งหมดของ [userId] จากเซิร์ฟเวอร์จริง ไม่ใช่จากแคช
  /// ต้องโยน error เมื่อออฟไลน์ (ไม่เช่นนั้นข้อมูลเก่าจะถูกตีความว่าถูกลบ)
  Future<List<MoodEntry>> fetchAll(String userId);

  /// เขียนรายการทั้งก้อน (ใช้ id และเวลาตามที่ส่งมา)
  Future<void> upsert(MoodEntry entry);

  Future<void> delete({required String userId, required String entryId});
}

/// เซิร์ฟเวอร์ปฏิเสธถาวร (เช่น ผิด Security Rules) ลองซ้ำก็ไม่สำเร็จ
/// ต่างจากปัญหาเครือข่ายที่ควรลองใหม่
class RemoteRejectedException implements Exception {
  const RemoteRejectedException(this.code);
  final String code;

  @override
  String toString() => 'RemoteRejectedException($code)';
}