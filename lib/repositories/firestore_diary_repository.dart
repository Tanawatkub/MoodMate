import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mood_entry.dart';
import 'diary_repository.dart';
import 'remote_diary_source.dart';

/// ตัวจริงที่เก็บข้อมูลบน Cloud Firestore
/// โครงสร้าง: users/{userId}/mood_entries/{entryId}
/// การแปลง Timestamp <-> DateTime ทำที่นี่ที่เดียว UI ไม่เห็น Timestamp
/// ห้าม log diaryText
///
/// พฤติกรรมตรงกับ MockDiaryRepository:
/// - คืนเฉพาะของ userId ที่ระบุ เรียงใหม่สุดก่อน
/// - ช่วงเวลา createdAt อยู่ใน [from, to)
/// - createEntry กำหนด id และเวลาเอง
/// - updateEntry ไม่เปลี่ยน createdAt ถ้าไม่พบรายการจะโยน StateError
/// - deleteEntry ของรายการที่ไม่มีจะไม่โยน error
///
/// ข้อผิดพลาดจาก Firestore (เช่น permission-denied, unavailable)
/// จะเป็น FirebaseException ให้ UI จับและแสดงสถานะ error
class FirestoreDiaryRepository implements DiaryRepository, RemoteDiarySource {
  FirestoreDiaryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _db.collection('users').doc(userId).collection('mood_entries');

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    Query<Map<String, dynamic>> query = _collection(userId);
    if (from != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (to != null) {
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(to));
    }
    query = query.orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async {
    final ref = _collection(entry.userId).doc();
    final now = DateTime.now();
    final created = entry.copyWith(id: ref.id, createdAt: now, updatedAt: now);
    await ref.set(_toMap(created));
    return created;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    final ref = _collection(entry.userId).doc(entry.id);

    // อ่านก่อนแก้ เพื่อแยก "ไม่พบรายการ" ออกจาก "ไม่มีสิทธิ์"
    // (update รายการที่ไม่มีอยู่ จะถูก Security Rules ตอบ permission-denied)
    // และใช้ createdAt เดิมจากฐานข้อมูล ไม่เชื่อค่าที่ UI ส่งมา
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      throw StateError('ไม่พบรายการ ${entry.id} ของผู้ใช้นี้');
    }

    final now = DateTime.now();
    // update() แก้เฉพาะ field ที่ระบุ จึงไม่แตะ createdAt และ userId
    await ref.update({
      'mood': entry.mood,
      'contextTags': entry.contextTags,
      'diaryText': entry.diaryText,
      'updatedAt': Timestamp.fromDate(now),
    });

    return _fromDoc(snapshot).copyWith(
      mood: entry.mood,
      contextTags: entry.contextTags,
      diaryText: entry.diaryText,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) {
    return _collection(userId).doc(entryId).delete();
  }

  // ---- ส่วนที่ SyncedDiaryRepository ใช้ซิงก์ (RemoteDiarySource) ----

  /// อ่านจากเซิร์ฟเวอร์จริงเท่านั้น (ออฟไลน์จะโยน error)
  @override
  Future<List<MoodEntry>> fetchAll(String userId) async {
    final snapshot = await _collection(userId)
        .orderBy('createdAt', descending: true)
        .get(const GetOptions(source: Source.server));
    return snapshot.docs.map(_fromDoc).toList();
  }

  /// เขียนรายการทั้งก้อนด้วย id และเวลาตามที่ส่งมา
  /// ถูก Rules ปฏิเสธ -> RemoteRejectedException (ไม่ใช่ปัญหาเครือข่าย)
  @override
  Future<void> upsert(MoodEntry entry) async {
    try {
      await _collection(entry.userId).doc(entry.id).set(_toMap(entry));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'invalid-argument') {
        throw RemoteRejectedException(e.code);
      }
      rethrow;
    }
  }

  @override
  Future<void> delete({required String userId, required String entryId}) async {
    try {
      await _collection(userId).doc(entryId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw RemoteRejectedException(e.code);
      rethrow;
    }
  }

  // ต้องมี key เท่านี้เท่านั้น (Security Rules ตรวจด้วย hasOnly) ห้ามใส่ id
  Map<String, dynamic> _toMap(MoodEntry e) => {
        'userId': e.userId,
        'mood': e.mood,
        'contextTags': e.contextTags,
        'diaryText': e.diaryText,
        'createdAt': Timestamp.fromDate(e.createdAt),
        'updatedAt': Timestamp.fromDate(e.updatedAt),
      };

  MoodEntry _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MoodEntry(
      id: doc.id,
      userId: data['userId'] as String,
      mood: data['mood'] as String,
      contextTags: List<String>.from(data['contextTags'] as List<dynamic>),
      diaryText: data['diaryText'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}