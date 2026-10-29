import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/hive_diary_store.dart';
import 'package:moodmate/repositories/local_diary_store.dart';

void main() {
  late Directory dir;

  MoodEntry entry(String userId, String id, {String text = 'ทดสอบ'}) => MoodEntry(
        id: id,
        userId: userId,
        mood: 'happy',
        contextTags: const ['Lab', 'Deadline'],
        diaryText: text,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(1700000000123456),
        updatedAt: DateTime.fromMicrosecondsSinceEpoch(1700000099987654),
      );

  HiveDiaryStore newStore() => HiveDiaryStore(init: () async {});

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('moodmate_hive_');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('put / get / all / remove', () async {
    final store = newStore();
    await store.put(LocalDiaryRecord(entry('A', 'e1'), SyncState.pending));
    await store.put(LocalDiaryRecord(entry('A', 'e2'), SyncState.synced));

    final got = await store.get('A', 'e1');
    expect(got!.entry.diaryText, 'ทดสอบ');
    expect(got.entry.contextTags, ['Lab', 'Deadline']);
    expect(got.state, SyncState.pending);
    expect((await store.all('A')).length, 2);

    await store.remove('A', 'e1');
    expect(await store.get('A', 'e1'), isNull);
    expect((await store.all('A')).length, 1);
  });

  test('แยกข้อมูลผู้ใช้แต่ละคน', () async {
    final store = newStore();
    await store.put(LocalDiaryRecord(entry('A', 'e1'), SyncState.synced));
    await store.put(LocalDiaryRecord(entry('B', 'e1'), SyncState.synced));
    expect((await store.all('A')).single.entry.userId, 'A');
    expect((await store.all('B')).single.entry.userId, 'B');
    expect(await store.all('C'), isEmpty);
  });

  test('ข้อมูลยังอยู่หลังปิดและเปิดใหม่ (จำลองปิดแอป) เวลาตรงเป๊ะ', () async {
    final original = entry('A', 'e1', text: 'ยังอยู่');
    final store = newStore();
    await store.put(LocalDiaryRecord(original, SyncState.pending));
    await store.setLastPull('A', DateTime.fromMicrosecondsSinceEpoch(1700000200000001));
    await store.close();

    final reopened = newStore();
    final back = await reopened.get('A', 'e1');
    expect(back!.entry.diaryText, 'ยังอยู่');
    expect(back.entry.createdAt, original.createdAt);
    expect(back.entry.updatedAt, original.updatedAt);
    expect(back.state, SyncState.pending);
    expect(
      await reopened.lastPull('A'),
      DateTime.fromMicrosecondsSinceEpoch(1700000200000001),
    );
    expect(await reopened.lastPull('B'), isNull);
  });

  test('ข้อมูลเสียถูกข้าม ไม่ทำให้ล่ม', () async {
    final store = newStore();
    await store.put(LocalDiaryRecord(entry('A', 'good'), SyncState.synced));
    final box = Hive.box<String>('diary_entries');
    await box.put('A|bad', 'ไม่ใช่ JSON');
    final list = await store.all('A');
    expect(list.map((r) => r.entry.id), ['good']);
    expect(await store.get('A', 'bad'), isNull);
  });
}