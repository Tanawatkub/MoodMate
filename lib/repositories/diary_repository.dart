import '../models/mood_entry.dart';

/// Interface กลางสำหรับอ่าน/เขียนรายการบันทึก
/// UI เรียกผ่าน interface นี้เท่านั้น ห้าม import Firestore ใน Widget
/// ห้ามเปลี่ยน signature โดยไม่คุยทีม
abstract class DiaryRepository {
  /// คืนเฉพาะรายการของ [userId]
  /// ช่วงเวลา (ข้อเสนอ ต้องให้ทีมยืนยัน): createdAt อยู่ใน [from, to)
  /// คือรวม [from] แต่ไม่รวม [to] ใช้แบบเดียวกันทุก implementation
  /// ถ้าไม่ระบุ [from] หรือ [to] คือไม่จำกัดฝั่งนั้น
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  });

  /// repository เป็นผู้กำหนด id และ createdAt/updatedAt ของรายการใหม่
  /// (ค่า id/เวลาที่ส่งเข้ามาถูกมองว่าเป็นค่าชั่วคราว)
  /// คืนรายการที่บันทึกแล้วพร้อมค่าจริง
  Future<MoodEntry> createEntry(MoodEntry entry);

  /// แก้ไขรายการเดิม ห้ามเปลี่ยน createdAt, อัปเดต updatedAt
  Future<MoodEntry> updateEntry(MoodEntry entry);

  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  });
}
