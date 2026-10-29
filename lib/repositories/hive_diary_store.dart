import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/mood_entry.dart';
import 'local_diary_store.dart';

/// Local database จริงด้วย Hive CE เก็บในไฟล์บนเครื่อง ไม่หายเมื่อปิดแอป
/// - กล่องเดียว key = "userId|entryId" แยกข้อมูลผู้ใช้ด้วย prefix
/// - ค่าเป็น JSON string (ไม่ต้องใช้ code generation)
/// - เวลาเก็บเป็นไมโครวินาที เพื่อให้ตรงกับ Timestamp ของ Firestore เป๊ะ
///   (Rules บังคับว่า createdAt ห้ามเปลี่ยน)
/// - เปิดกล่องแบบ lazy และเรียก Hive.initFlutter() เองครั้งแรกที่ใช้
/// ข้อมูลไม่ได้เข้ารหัส (อยู่ในพื้นที่ส่วนตัวของแอปบน Android)
class HiveDiaryStore implements LocalDiaryStore {
  /// [init] ใช้แทนการเตรียม Hive ตอนทดสอบ (เช่น Hive.init(dir) ใน unit test)
  HiveDiaryStore({Future<void> Function()? init, this.boxName = 'diary_entries'})
      : _init = init ?? _initFlutter;

  static Future<void>? _flutterInit;
  static Future<void> _initFlutter() => _flutterInit ??= Hive.initFlutter();

  final Future<void> Function() _init;
  final String boxName;
  Future<Box<String>>? _boxFuture;

  Future<Box<String>> _box() => _boxFuture ??= _open();

  Future<Box<String>> _open() async {
    await _init();
    return Hive.openBox<String>(boxName);
  }

  /// ปิดกล่อง (ใช้ตอนทดสอบเพื่อจำลองการปิดแอป)
  Future<void> close() async {
    final future = _boxFuture;
    _boxFuture = null;
    if (future != null) {
      final box = await future;
      await box.close();
    }
  }

  static String _key(String userId, String entryId) => '$userId|$entryId';
  static String _metaKey(String userId) => '~lastPull|$userId';

  @override
  Future<List<LocalDiaryRecord>> all(String userId) async {
    final box = await _box();
    final prefix = '$userId|';
    final result = <LocalDiaryRecord>[];
    for (final key in box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      final record = _decode(raw);
      if (record != null) result.add(record);
    }
    return result;
  }

  @override
  Future<LocalDiaryRecord?> get(String userId, String entryId) async {
    final box = await _box();
    final raw = box.get(_key(userId, entryId));
    return raw == null ? null : _decode(raw);
  }

  @override
  Future<void> put(LocalDiaryRecord record) async {
    final box = await _box();
    await box.put(_key(record.entry.userId, record.entry.id), _encode(record));
  }

  @override
  Future<void> remove(String userId, String entryId) async {
    final box = await _box();
    await box.delete(_key(userId, entryId));
  }

  @override
  Future<DateTime?> lastPull(String userId) async {
    final box = await _box();
    final micros = int.tryParse(box.get(_metaKey(userId)) ?? '');
    return micros == null ? null : DateTime.fromMicrosecondsSinceEpoch(micros);
  }

  @override
  Future<void> setLastPull(String userId, DateTime time) async {
    final box = await _box();
    await box.put(_metaKey(userId), time.microsecondsSinceEpoch.toString());
  }

  String _encode(LocalDiaryRecord r) => jsonEncode({
        'id': r.entry.id,
        'userId': r.entry.userId,
        'mood': r.entry.mood,
        'contextTags': r.entry.contextTags,
        'diaryText': r.entry.diaryText,
        'createdAt': r.entry.createdAt.microsecondsSinceEpoch,
        'updatedAt': r.entry.updatedAt.microsecondsSinceEpoch,
        'state': r.state.name,
      });

  /// ข้อมูลเสีย/อ่านไม่ได้ จะถูกข้าม ไม่ทำให้แอปล่ม
  LocalDiaryRecord? _decode(String raw) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final entry = MoodEntry(
        id: m['id'] as String,
        userId: m['userId'] as String,
        mood: m['mood'] as String,
        contextTags: List<String>.from(m['contextTags'] as List<dynamic>),
        diaryText: m['diaryText'] as String,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(m['createdAt'] as int),
        updatedAt: DateTime.fromMicrosecondsSinceEpoch(m['updatedAt'] as int),
      );
      return LocalDiaryRecord(entry, SyncState.values.byName(m['state'] as String));
    } catch (_) {
      return null;
    }
  }
}