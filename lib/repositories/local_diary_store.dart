import '../models/mood_entry.dart';

/// สถานะการซิงก์ของรายการในเครื่อง
enum SyncState {
  /// ตรงกับเซิร์ฟเวอร์แล้ว
  synced,

  /// สร้าง/แก้ในเครื่อง รอส่งขึ้นเซิร์ฟเวอร์
  pending,

  /// ผู้ใช้ลบแล้ว รอลบบนเซิร์ฟเวอร์ (ซ่อนจากหน้าจอ)
  deleted,

  /// เซิร์ฟเวอร์ปฏิเสธ (เช่น ผิด Rules) ไม่ลองซ้ำจนกว่าจะแก้รายการ
  rejected,
}

class LocalDiaryRecord {
  const LocalDiaryRecord(this.entry, this.state);
  final MoodEntry entry;
  final SyncState state;
}

/// ที่เก็บข้อมูลในเครื่อง (ตัวจริงคือ HiveDiaryStore) แยกข้อมูลตาม userId
abstract class LocalDiaryStore {
  Future<List<LocalDiaryRecord>> all(String userId);
  Future<LocalDiaryRecord?> get(String userId, String entryId);
  Future<void> put(LocalDiaryRecord record);
  Future<void> remove(String userId, String entryId);

  /// เวลาที่ดึงข้อมูลจากเซิร์ฟเวอร์สำเร็จครั้งล่าสุด null = ยังไม่เคย
  Future<DateTime?> lastPull(String userId);
  Future<void> setLastPull(String userId, DateTime time);
}

/// เก็บในหน่วยความจำ ใช้ทดสอบ (หายเมื่อปิดแอป)
class InMemoryLocalDiaryStore implements LocalDiaryStore {
  final Map<String, LocalDiaryRecord> _records = {};
  final Map<String, DateTime> _lastPull = {};

  String _key(String userId, String entryId) => '$userId|$entryId';

  @override
  Future<List<LocalDiaryRecord>> all(String userId) async =>
      _records.values.where((r) => r.entry.userId == userId).toList();

  @override
  Future<LocalDiaryRecord?> get(String userId, String entryId) async =>
      _records[_key(userId, entryId)];

  @override
  Future<void> put(LocalDiaryRecord record) async {
    _records[_key(record.entry.userId, record.entry.id)] = record;
  }

  @override
  Future<void> remove(String userId, String entryId) async {
    _records.remove(_key(userId, entryId));
  }

  @override
  Future<DateTime?> lastPull(String userId) async => _lastPull[userId];

  @override
  Future<void> setLastPull(String userId, DateTime time) async {
    _lastPull[userId] = time;
  }
}