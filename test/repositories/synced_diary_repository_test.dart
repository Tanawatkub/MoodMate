import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/local_diary_store.dart';
import 'package:moodmate/repositories/remote_diary_source.dart';
import 'package:moodmate/repositories/synced_diary_repository.dart';

/// เซิร์ฟเวอร์ปลอมที่สั่งออฟไลน์/ปฏิเสธได้
class FakeRemote implements RemoteDiarySource {
  bool online = true;
  bool reject = false;
  final Map<String, MoodEntry> data = {};
  Future<void> Function(MoodEntry entry)? onUpsert;

  void _check() {
    if (!online) throw StateError('offline');
  }

  @override
  Future<List<MoodEntry>> fetchAll(String userId) async {
    _check();
    return data.values.where((e) => e.userId == userId).toList();
  }

  @override
  Future<void> upsert(MoodEntry entry) async {
    _check();
    if (reject) throw const RemoteRejectedException('permission-denied');
    final hook = onUpsert;
    if (hook != null) await hook(entry);
    data['${entry.userId}|${entry.id}'] = entry;
  }

  @override
  Future<void> delete({required String userId, required String entryId}) async {
    _check();
    data.remove('$userId|$entryId');
  }
}

void main() {
  late InMemoryLocalDiaryStore local;
  late FakeRemote remote;
  late SyncedDiaryRepository repo;
  var clock = DateTime(2026, 1, 15, 12);

  MoodEntry draft(String userId,
          {String mood = 'happy', String text = 'ทดสอบ', List<String>? tags}) =>
      MoodEntry(
        id: '',
        userId: userId,
        mood: mood,
        contextTags: tags ?? const ['Lab'],
        diaryText: text,
        createdAt: DateTime(2000),
        updatedAt: DateTime(2000),
      );

  MoodEntry remoteEntry(String id, String userId, {String text = 'remote'}) =>
      MoodEntry(
        id: id,
        userId: userId,
        mood: 'sad',
        contextTags: const ['Deadline'],
        diaryText: text,
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 10),
      );

  setUp(() {
    clock = DateTime(2026, 1, 15, 12);
    local = InMemoryLocalDiaryStore();
    remote = FakeRemote();
    repo = SyncedDiaryRepository(local: local, remote: remote, now: () => clock);
  });

  tearDown(() => repo.dispose());

  test('สร้างตอนออฟไลน์: เห็นในเครื่องทันที แล้วซิงก์ขึ้นเมื่อกลับมาออนไลน์', () async {
    remote.online = false;
    final e = await repo.createEntry(draft('A'));
    expect(e.id, isNotEmpty);

    final list = await repo.getEntries(userId: 'A');
    expect(list.map((x) => x.id), [e.id]);
    expect(remote.data, isEmpty);
    await pumpEventQueue();
    expect(await repo.pendingCount('A'), 1);

    remote.online = true;
    await repo.syncNow('A');
    expect(remote.data.length, 1);
    expect(await repo.pendingCount('A'), 0);
    expect((await local.all('A')).single.state, SyncState.synced);
  });

  test('updateEntry ไม่เปลี่ยน createdAt และซิงก์ขึ้นเซิร์ฟเวอร์', () async {
    final e = await repo.createEntry(draft('A'));
    await repo.syncNow('A');
    clock = clock.add(const Duration(hours: 1));
    final u = await repo.updateEntry(e.copyWith(diaryText: 'แก้แล้ว'));
    expect(u.createdAt, e.createdAt);
    expect(u.updatedAt, clock);
    await pumpEventQueue();
    await repo.syncNow('A');
    expect(remote.data.values.single.diaryText, 'แก้แล้ว');
  });

  test('deleteEntry ซ่อนทันที แล้วลบบนเซิร์ฟเวอร์เมื่อซิงก์', () async {
    final e = await repo.createEntry(draft('A'));
    await repo.syncNow('A');
    await repo.deleteEntry(userId: 'A', entryId: e.id);
    expect(await repo.getEntries(userId: 'A'), isEmpty);
    await pumpEventQueue();
    await repo.syncNow('A');
    expect(remote.data, isEmpty);
    expect(await local.all('A'), isEmpty);
  });

  test('เครื่องใหม่: getEntries ครั้งแรกดึงข้อมูลจากเซิร์ฟเวอร์ลงเครื่อง', () async {
    remote.data['A|r1'] = remoteEntry('r1', 'A');
    final list = await repo.getEntries(userId: 'A');
    expect(list.single.id, 'r1');
    expect((await local.all('A')).single.state, SyncState.synced);
  });

  test('รายการที่ถูกลบจากเครื่องอื่น หายจากเครื่องนี้เมื่อซิงก์', () async {
    remote.data['A|r1'] = remoteEntry('r1', 'A');
    await repo.getEntries(userId: 'A');
    remote.data.clear();
    await pumpEventQueue();
    await repo.syncNow('A');
    expect(await local.all('A'), isEmpty);
  });

  test('แก้ในเครื่องที่ยังไม่ส่ง ชนะข้อมูลบนเซิร์ฟเวอร์', () async {
    remote.data['A|r1'] = remoteEntry('r1', 'A');
    await repo.getEntries(userId: 'A');
    await pumpEventQueue();

    remote.online = false;
    clock = clock.add(const Duration(hours: 1));
    await repo.updateEntry(remoteEntry('r1', 'A', text: 'local'));
    await pumpEventQueue();
    remote.data['A|r1'] = remoteEntry('r1', 'A', text: 'remote2');

    remote.online = true;
    await repo.syncNow('A');
    expect(remote.data['A|r1']!.diaryText, 'local');
    expect((await local.all('A')).single.entry.diaryText, 'local');
  });

  test('แก้ระหว่างที่กำลังส่ง: ไม่ทับด้วยสถานะเก่า และส่งเวอร์ชันใหม่ตามไป', () async {
    remote.onUpsert = (pushed) async {
      if (pushed.diaryText == 'v1') {
        clock = clock.add(const Duration(minutes: 1));
        await repo.updateEntry(pushed.copyWith(diaryText: 'v2'));
      }
    };
    await repo.createEntry(draft('A', text: 'v1'));
    await repo.syncNow('A');
    expect(remote.data.values.single.diaryText, 'v2');
    expect(await repo.pendingCount('A'), 0);
  });

  test('ข้อมูลของผู้ใช้แต่ละคนแยกกัน', () async {
    await repo.createEntry(draft('A'));
    expect(await repo.getEntries(userId: 'B'), isEmpty);
    expect((await repo.getEntries(userId: 'A')).length, 1);
  });

  test('ช่วงเวลา [from, to) และเรียงใหม่สุดก่อน', () async {
    final e1 = await repo.createEntry(draft('A'));
    clock = clock.add(const Duration(days: 1));
    final e2 = await repo.createEntry(draft('A'));

    final inc = await repo.getEntries(userId: 'A', from: e2.createdAt);
    expect(inc.map((e) => e.id), [e2.id]);
    final exc = await repo.getEntries(userId: 'A', to: e2.createdAt);
    expect(exc.map((e) => e.id), [e1.id]);
    final all = await repo.getEntries(userId: 'A');
    expect(all.first.id, e2.id);
  });

  test('ออฟไลน์: getEntries ไม่โยน error, แก้ที่ไม่มี -> StateError, ลบที่ไม่มี -> ไม่โยน',
      () async {
    remote.online = false;
    expect(await repo.getEntries(userId: 'A'), isEmpty);
    expect(
      () => repo.updateEntry(draft('A').copyWith(id: 'nope')),
      throwsStateError,
    );
    await repo.deleteEntry(userId: 'A', entryId: 'nope');
  });

  test('รายการที่เซิร์ฟเวอร์ปฏิเสธ ไม่บล็อกรายการอื่น', () async {
    remote.reject = true;
    final bad = await repo.createEntry(draft('A', mood: 'meh'));
    await repo.syncNow('A');
    expect((await local.get('A', bad.id))!.state, SyncState.rejected);

    remote.reject = false;
    final good = await repo.createEntry(draft('A'));
    await repo.syncNow('A');
    expect(remote.data.values.map((e) => e.id), [good.id]);
    expect((await local.get('A', bad.id))!.state, SyncState.rejected);
  });

  test('changes ส่งสัญญาณเมื่อดึงข้อมูลใหม่ลงเครื่อง', () async {
    remote.data['A|r1'] = remoteEntry('r1', 'A');
    var events = 0;
    final sub = repo.changes.listen((_) => events++);
    await repo.getEntries(userId: 'A');
    await pumpEventQueue();
    expect(events, greaterThan(0));
    await sub.cancel();
  });
}