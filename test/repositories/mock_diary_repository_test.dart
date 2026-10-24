import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/mock_diary_repository.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 15, 12);

  MoodEntry draft(String userId, {String mood = 'happy'}) => MoodEntry(
        id: '',
        userId: userId,
        mood: mood,
        contextTags: const ['Lab'],
        diaryText: 'ทดสอบ',
        createdAt: DateTime(2000),
        updatedAt: DateTime(2000),
      );

  test('createEntry กำหนด id และเวลาเอง', () async {
    final repo = MockDiaryRepository(now: () => fixedNow);
    final e = await repo.createEntry(draft('A'));
    expect(e.id, isNotEmpty);
    expect(e.createdAt, fixedNow);
    expect(e.updatedAt, fixedNow);
  });

  test('getEntries คืนเฉพาะของ user ที่ระบุ', () async {
    final repo = MockDiaryRepository(now: () => fixedNow);
    await repo.createEntry(draft('A'));
    await repo.createEntry(draft('B'));
    final a = await repo.getEntries(userId: 'A');
    expect(a.length, 1);
    expect(a.single.userId, 'A');
  });

  test('ช่วงเวลา [from, to) รวม from ไม่รวม to', () async {
    final repo = MockDiaryRepository(now: () => fixedNow);
    await repo.createEntry(draft('A')); // createdAt = fixedNow
    final includesFrom =
        await repo.getEntries(userId: 'A', from: fixedNow);
    final excludesTo = await repo.getEntries(userId: 'A', to: fixedNow);
    expect(includesFrom.length, 1);
    expect(excludesTo, isEmpty);
  });

  test('updateEntry ไม่เปลี่ยน createdAt', () async {
    var t = fixedNow;
    final repo = MockDiaryRepository(now: () => t);
    final created = await repo.createEntry(draft('A'));
    t = fixedNow.add(const Duration(hours: 1));
    final updated =
        await repo.updateEntry(created.copyWith(diaryText: 'แก้แล้ว'));
    expect(updated.createdAt, fixedNow);
    expect(updated.updatedAt, t);
    expect(updated.diaryText, 'แก้แล้ว');
  });

  test('user อื่นแก้/ลบรายการของ A ไม่ได้', () async {
    final repo = MockDiaryRepository(now: () => fixedNow);
    final created = await repo.createEntry(draft('A'));
    expect(
      () => repo.updateEntry(created.copyWith(userId: 'B')),
      throwsStateError,
    );
    await repo.deleteEntry(userId: 'B', entryId: created.id);
    expect((await repo.getEntries(userId: 'A')).length, 1);
    await repo.deleteEntry(userId: 'A', entryId: created.id);
    expect(await repo.getEntries(userId: 'A'), isEmpty);
  });

  test('seedSamples สร้างข้อมูลตัวอย่างหลายรายการ ใหม่สุดก่อน', () async {
    final repo =
        MockDiaryRepository(sampleUserId: 'A', now: () => fixedNow);
    final list = await repo.getEntries(userId: 'A');
    expect(list.length, greaterThan(5));
    expect(list.first.createdAt.isAfter(list.last.createdAt), isTrue);
  });
}