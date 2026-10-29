import 'dart:async';
import 'dart:math';

import '../models/mood_entry.dart';
import 'diary_repository.dart';
import 'local_diary_store.dart';
import 'remote_diary_source.dart';

/// DiaryRepository แบบ "เขียนในเครื่องก่อน ซิงก์ขึ้นคลาวด์ทีหลัง"
/// - อ่าน/เขียนที่ Local database (Hive) เสมอ จึงใช้ได้ตอนไม่มีอินเทอร์เน็ต
/// - รายการที่ยังไม่ส่งจะมีสถานะ pending แล้วส่งขึ้น Firestore เมื่อออนไลน์
/// - Firestore เป็นแหล่งความจริง: ดึงข้อมูลลงเครื่องเมื่อซิงก์ รายการที่ยังไม่ส่งในเครื่องชนะ
/// - สัญญาเดียวกับ DiaryRepository (เรียงใหม่สุดก่อน, ช่วง [from, to),
///   updateEntry ไม่พบรายการ -> StateError, deleteEntry ไม่พบ -> ไม่โยน error)
///
/// ตัวกระตุ้นการซิงก์: หลังเขียน, ตอน getEntries (ถ้าข้อมูลเก่าเกิน [syncInterval]
/// หรือยังมีรายการค้าง) และเรียก [syncNow] เอง (เช่น ปุ่มรีเฟรช)
/// ยังไม่มีตัวฟังสถานะเครือข่าย: ถ้ากลับมาออนไลน์ จะซิงก์ครั้งถัดไปที่มีการกระตุ้น
class SyncedDiaryRepository implements DiaryRepository {
  SyncedDiaryRepository({
    required this.local,
    required this.remote,
    this.remoteTimeout = const Duration(seconds: 15),
    this.initialPullTimeout = const Duration(seconds: 8),
    this.syncInterval = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final LocalDiaryStore local;
  final RemoteDiarySource remote;

  /// เวลารอสูงสุดต่อคำสั่งฝั่งเซิร์ฟเวอร์ (ออฟไลน์ Firestore อาจค้างรอ)
  final Duration remoteTimeout;

  /// เวลาที่ getEntries จะรอดึงข้อมูลครั้งแรก (เครื่องที่ยังไม่มีข้อมูลเลย)
  final Duration initialPullTimeout;

  /// ซิงก์เบื้องหลังไม่ถี่กว่านี้ เพื่อลดจำนวนการอ่าน Firestore
  final Duration syncInterval;

  final DateTime Function() _now;

  final Map<String, Future<void>> _inFlight = {};
  final Set<String> _dirty = {};
  final Set<String> _triedRejected = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// ส่งสัญญาณเมื่อการซิงก์ดึงข้อมูลใหม่ลงเครื่อง (หน้าจอจะโหลดรายการซ้ำก็ได้)
  Stream<void> get changes => _changes.stream;

  Future<void> dispose() => _changes.close();

  /// จำนวนรายการที่ยังรอส่งขึ้นคลาวด์ (ไว้แสดง "รอซิงก์ n รายการ")
  Future<int> pendingCount(String userId) async {
    final records = await local.all(userId);
    return records.where((r) => r.state == SyncState.pending).length;
  }

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    var records = await local.all(userId);
    final lastPull = await local.lastPull(userId);

    if (records.isEmpty && lastPull == null) {
      // เครื่องนี้ยังไม่เคยดึงข้อมูลของผู้ใช้นี้ ลองดึงก่อนแสดงผล (ไม่รอนาน)
      try {
        await syncNow(userId).timeout(initialPullTimeout);
      } catch (_) {
        // ออฟไลน์/ช้า: แสดงข้อมูลในเครื่อง (ว่าง) ไปก่อน
      }
      records = await local.all(userId);
    } else {
      final hasUnsynced = records.any(
        (r) => r.state == SyncState.pending || r.state == SyncState.deleted,
      );
      final stale = lastPull == null || _now().difference(lastPull) >= syncInterval;
      if (hasUnsynced || stale) _syncInBackground(userId);
    }

    final result = records
        .where((r) => r.state != SyncState.deleted)
        .map((r) => r.entry)
        .where((e) {
      if (from != null && e.createdAt.isBefore(from)) return false;
      if (to != null && !e.createdAt.isBefore(to)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // ใหม่สุดก่อน
    return result;
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async {
    final t = _now();
    final created = entry.copyWith(id: _newId(), createdAt: t, updatedAt: t);
    await local.put(LocalDiaryRecord(created, SyncState.pending));
    _afterLocalWrite(created.userId);
    return created;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    final existing = await local.get(entry.userId, entry.id);
    if (existing == null || existing.state == SyncState.deleted) {
      throw StateError('ไม่พบรายการ ${entry.id} ของผู้ใช้นี้');
    }
    final updated = existing.entry.copyWith(
      mood: entry.mood,
      contextTags: entry.contextTags,
      diaryText: entry.diaryText,
      updatedAt: _now(), // createdAt คงเดิม
    );
    await local.put(LocalDiaryRecord(updated, SyncState.pending));
    _afterLocalWrite(updated.userId);
    return updated;
  }

  @override
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
    final existing = await local.get(userId, entryId);
    if (existing == null || existing.state == SyncState.deleted) return;
    await local.put(LocalDiaryRecord(existing.entry, SyncState.deleted));
    _afterLocalWrite(userId);
  }

  /// ซิงก์ตอนนี้: ส่งรายการค้างขึ้นก่อน แล้วดึงข้อมูลจากเซิร์ฟเวอร์ลงเครื่อง
  /// ถ้ามีการซิงก์ของผู้ใช้นี้กำลังทำอยู่ จะคืน Future ตัวเดิม
  /// ล้มเหลวเมื่อออฟไลน์ (โยน error) ผู้เรียกต้องจับเอง
  Future<void> syncNow(String userId) {
    final running = _inFlight[userId];
    if (running != null) return running;
    final future = _runSync(userId).whenComplete(() {
      _inFlight.remove(userId);
    });
    _inFlight[userId] = future;
    return future;
  }

  void _afterLocalWrite(String userId) {
    _dirty.add(userId);
    _syncInBackground(userId);
  }

  void _syncInBackground(String userId) {
    unawaited(syncNow(userId).then<void>((_) {}, onError: (Object _) {}));
  }

  Future<void> _runSync(String userId) async {
    var changed = false;
    do {
      _dirty.remove(userId);
      await _push(userId);
      final remoteEntries = await remote.fetchAll(userId).timeout(remoteTimeout);
      if (await _merge(userId, remoteEntries)) changed = true;
      await local.setLastPull(userId, _now());
    } while (_dirty.contains(userId)); // มีการเขียนใหม่ระหว่างซิงก์ ทำซ้ำ
    if (changed && !_changes.isClosed) _changes.add(null);
  }

  Future<void> _push(String userId) async {
    final records = await local.all(userId);
    for (final r in records) {
      final id = r.entry.id;
      if (r.state == SyncState.deleted) {
        try {
          await remote.delete(userId: userId, entryId: id).timeout(remoteTimeout);
        } on RemoteRejectedException {
          // ลบบนเซิร์ฟเวอร์ไม่ได้ ถือว่าจบ ไม่ให้คิวค้าง
        }
        final current = await local.get(userId, id);
        if (current != null && current.state == SyncState.deleted) {
          await local.remove(userId, id);
        }
      } else if (r.state == SyncState.pending ||
          (r.state == SyncState.rejected && !_triedRejected.contains(id))) {
        var result = SyncState.synced;
        try {
          await remote.upsert(r.entry).timeout(remoteTimeout);
        } on RemoteRejectedException {
          _triedRejected.add(id); // ลองใหม่อีกครั้งในรอบแอปถัดไป (กรณี logout ระหว่างส่ง)
          result = SyncState.rejected;
        }
        // ถ้าผู้ใช้แก้รายการระหว่างที่ส่งอยู่ ห้ามทับด้วยสถานะเก่า
        final current = await local.get(userId, id);
        if (current != null &&
            (current.state == SyncState.pending ||
                current.state == SyncState.rejected) &&
            current.entry.updatedAt.isAtSameMomentAs(r.entry.updatedAt)) {
          await local.put(LocalDiaryRecord(r.entry, result));
        }
      }
    }
  }

  /// รวมข้อมูลจากเซิร์ฟเวอร์ลงเครื่อง คืน true ถ้ามีอะไรเปลี่ยน
  Future<bool> _merge(String userId, List<MoodEntry> remoteEntries) async {
    var changed = false;
    final localById = {
      for (final r in await local.all(userId)) r.entry.id: r,
    };
    final remoteIds = <String>{};

    for (final e in remoteEntries) {
      remoteIds.add(e.id);
      final l = localById[e.id];
      if (l == null) {
        await local.put(LocalDiaryRecord(e, SyncState.synced));
        changed = true;
      } else if (l.state == SyncState.synced && !_same(l.entry, e)) {
        await local.put(LocalDiaryRecord(e, SyncState.synced));
        changed = true;
      }
      // pending / deleted / rejected: ฝั่งเครื่องชนะ จะถูกส่งขึ้นในรอบซิงก์
    }

    // รายการที่เคยตรงกับเซิร์ฟเวอร์ แต่หายไป = ถูกลบจากเครื่องอื่น
    for (final l in localById.values) {
      if (l.state == SyncState.synced && !remoteIds.contains(l.entry.id)) {
        await local.remove(userId, l.entry.id);
        changed = true;
      }
    }
    return changed;
  }

  bool _same(MoodEntry a, MoodEntry b) =>
      a.mood == b.mood &&
      a.diaryText == b.diaryText &&
      a.contextTags.join('\u0000') == b.contextTags.join('\u0000') &&
      a.createdAt.isAtSameMomentAs(b.createdAt) &&
      a.updatedAt.isAtSameMomentAs(b.updatedAt);

  /// id ที่สร้างในเครื่อง (ใช้เป็นชื่อเอกสารใน Firestore ได้ ไม่ซ้ำกันในทางปฏิบัติ)
  String _newId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }
}