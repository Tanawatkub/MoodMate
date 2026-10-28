import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_loader.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/repositories/diary_repository.dart';

/// repository ปลอมสำหรับทดสอบ จดค่าที่ถูกเรียกไว้ตรวจ
class FakeDiaryRepository implements DiaryRepository {
  FakeDiaryRepository(this.entries, {this.error});

  final List<MoodEntry> entries;
  final Object? error;

  String? lastUserId;
  DateTime? lastFrom;
  DateTime? lastTo;

  @override
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    lastUserId = userId;
    lastFrom = from;
    lastTo = to;
    if (error != null) throw error!;
    return entries;
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) =>
      throw UnimplementedError();

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) =>
      throw UnimplementedError();

  @override
  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) =>
      throw UnimplementedError();
}

MoodEntry entry(String id, String mood, List<String> tags, DateTime time) {
  return MoodEntry(
    id: id,
    userId: 'u1',
    mood: mood,
    contextTags: tags,
    diaryText: 'test',
    createdAt: time,
    updatedAt: time,
  );
}

void main() {
  final now = DateTime(2026, 10, 25, 12);

  test('ส่ง userId และช่วง [start, end) ให้ repository', () async {
    final repo = FakeDiaryRepository([]);
    final loader = WeeklyInsightLoader(
      repository: repo,
      userId: 'u1',
      now: () => now,
    );

    await loader.load();

    expect(repo.lastUserId, 'u1');
    expect(repo.lastFrom, DateTime(2026, 10, 19));
    expect(repo.lastTo, DateTime(2026, 10, 26));
  });

  test('คำนวณสรุปจากรายการที่ได้ และไม่นับรายการนอกช่วง', () async {
    final repo = FakeDiaryRepository([
      entry('1', 'happy', ['Lab'], DateTime(2026, 10, 20, 9)),
      entry('2', 'happy', ['Lab', 'Deadline'], DateTime(2026, 10, 25, 22)),
      entry('3', 'sad', [], DateTime(2026, 10, 10, 9)), // นอกช่วง
    ]);
    final loader = WeeklyInsightLoader(
      repository: repo,
      userId: 'u1',
      now: () => now,
    );

    final r = await loader.load();

    expect(r.totalEntries, 2);
    expect(r.moodCounts, {'happy': 2});
    expect(r.contextCounts, {'Lab': 2, 'Deadline': 1});
    expect(r.weekStart, DateTime(2026, 10, 19));
    expect(r.weekEnd, DateTime(2026, 10, 26));
  });

  test('repository ล้มเหลว ส่ง error ต่อให้หน้าจอจัดการ', () async {
    final repo = FakeDiaryRepository([], error: StateError('offline'));
    final loader = WeeklyInsightLoader(
      repository: repo,
      userId: 'u1',
      now: () => now,
    );

    expect(loader.load(), throwsA(isA<StateError>()));
  });
}