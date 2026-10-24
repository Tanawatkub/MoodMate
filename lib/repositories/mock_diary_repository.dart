import '../models/mood_entry.dart';
import 'diary_repository.dart';

/// Repository จำลองเก็บข้อมูลในหน่วยความจำ (หายเมื่อปิดแอป)
/// ใช้แทน FirestoreDiaryRepository ระหว่างพัฒนา UI และ Weekly Insight
/// พฤติกรรมต้องตรงกับ [DiaryRepository] ทุกข้อ:
/// - คืนเฉพาะรายการของ userId ที่ระบุ
/// - ช่วงเวลา createdAt อยู่ใน [from, to)
/// - createEntry กำหนด id และเวลาให้เอง
/// - updateEntry ไม่เปลี่ยน createdAt
/// ข้อมูลตัวอย่างเป็นข้อมูลสมมติ ไม่ใช่ Diary จริง
class MockDiaryRepository implements DiaryRepository {
  /// [sampleUserId] ถ้าระบุ จะสร้างข้อมูลตัวอย่างของ user นั้นให้ทันที
  /// [latency] หน่วงเวลาตอบ ใช้ทดสอบหน้า loading ของ UI (ค่าเริ่มต้นไม่หน่วง)
  /// [now] ใช้กำหนดเวลาปัจจุบันตอนทดสอบ (ค่าเริ่มต้นคือ DateTime.now)
  MockDiaryRepository({
    String? sampleUserId,
    this.latency = Duration.zero,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    if (sampleUserId != null) {
      seedSamples(sampleUserId);
    }
  }

  final Duration latency;
  final DateTime Function() _now;
  final List<MoodEntry> _entries = [];
  int _nextId = 1;

  String _newId() => 'mock-${_nextId++}';

  Future<void> _wait() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }

  /// เพิ่มข้อมูลตัวอย่างย้อนหลังประมาณ 2 สัปดาห์ให้ [userId]
  /// เวลาอิงจากปัจจุบัน เพื่อให้ Dashboard รายสัปดาห์มีข้อมูลเสมอ
  void seedSamples(String userId) {
    final n = _now();
    // (กี่วันก่อน, กี่ชั่วโมงก่อนในวันนั้น, mood, tags, ข้อความ)
    final samples = <(int, int, String, List<String>, String)>[
      (0, 2, 'happy', ['Project'], 'งานกลุ่มคืบหน้าดี รู้สึกโล่งขึ้น'),
      (1, 3, 'sad', ['Lab', 'Deadline'], 'แล็บใกล้ส่งแต่ยังไม่เสร็จ รู้สึกกดดัน'),
      (2, 5, 'neutral', ['Coding'], 'วันปกติ นั่งเขียนโค้ดทั้งบ่าย'),
      (3, 4, 'angry', ['Group Work'], 'ประชุมกลุ่มแล้วงานไม่เป็นไปตามนัด หงุดหงิดนิดหน่อย'),
      (4, 6, 'happy', ['Presentation'], 'พรีเซนต์ผ่านไปได้ด้วยดี'),
      (5, 2, 'sad', ['Personal'], 'มีเรื่องที่บ้านทำให้คิดมากนิดหน่อย'),
      (6, 5, 'neutral', ['Coding', 'Project'], 'ทำฟีเจอร์ไปได้ครึ่งหนึ่ง'),
      (7, 3, 'neutral', [], 'วันนี้ไม่มีอะไรพิเศษ'),
      (8, 4, 'sad', ['Deadline'], 'งานเยอะ กลัวส่งไม่ทัน'),
      (9, 6, 'neutral', ['Lab'], 'ทำแล็บเสร็จตามแผน'),
      (10, 2, 'angry', ['Coding', 'Deadline'], 'หาบั๊กไม่เจอทั้งคืน'),
      (12, 5, 'happy', ['Personal'], 'ได้พักผ่อนและไปเที่ยวกับเพื่อน'),
    ];

    for (final s in samples) {
      final t = n.subtract(Duration(days: s.$1, hours: s.$2));
      _entries.add(MoodEntry(
        id: _newId(),
        userId: userId,
        mood: s.$3,
        contextTags: List<String>.of(s.$4),
        diaryText: s.$5,
        createdAt: t,
        updatedAt: t,
      ));
    }
  }

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    await _wait();
    final result = _entries.where((e) {
      if (e.userId != userId) return false;
      if (from != null && e.createdAt.isBefore(from)) return false;
      if (to != null && !e.createdAt.isBefore(to)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // ใหม่สุดก่อน
    return result;
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async {
    await _wait();
    final t = _now();
    final created = entry.copyWith(
      id: _newId(),
      createdAt: t,
      updatedAt: t,
    );
    _entries.add(created);
    return created;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    await _wait();
    final i = _entries.indexWhere(
      (e) => e.id == entry.id && e.userId == entry.userId,
    );
    if (i == -1) {
      throw StateError('ไม่พบรายการ ${entry.id} ของผู้ใช้นี้');
    }
    final updated = entry.copyWith(
      createdAt: _entries[i].createdAt, // ห้ามเปลี่ยน createdAt
      updatedAt: _now(),
    );
    _entries[i] = updated;
    return updated;
  }

  @override
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
    await _wait();
    _entries.removeWhere((e) => e.id == entryId && e.userId == userId);
  }
}