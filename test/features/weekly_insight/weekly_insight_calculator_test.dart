import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_calculator.dart';
import 'package:moodmate/models/mood_entry.dart';
import 'package:moodmate/models/weekly_insight.dart';

MoodEntry makeEntry({
  required String id,
  required String mood,
  required List<String> tags,
  required DateTime createdAt,
}) {
  return MoodEntry(
    id: id,
    userId: 'test-user',
    mood: mood,
    contextTags: tags,
    diaryText: 'test',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  final calculator = WeeklyInsightCalculator();
  final weekStart = DateTime(2026, 10, 19);
  final weekEnd = DateTime(2026, 10, 26);

  WeeklyInsight run(List<MoodEntry> entries) => calculator.calculate(
        entries: entries,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );

  test('รายการว่าง ได้ผลเป็น 0 ทั้งหมด', () {
    final r = run([]);
    expect(r.totalEntries, 0);
    expect(r.moodCounts, isEmpty);
    expect(r.contextCounts, isEmpty);
  });

  test('นับ mood ถูกต้อง', () {
    final r = run([
      makeEntry(id: '1', mood: 'happy', tags: [], createdAt: DateTime(2026, 10, 20)),
      makeEntry(id: '2', mood: 'happy', tags: [], createdAt: DateTime(2026, 10, 21)),
      makeEntry(id: '3', mood: 'sad', tags: [], createdAt: DateTime(2026, 10, 22)),
    ]);
    expect(r.totalEntries, 3);
    expect(r.moodCounts['happy'], 2);
    expect(r.moodCounts['sad'], 1);
  });

  test('หลาย tag ในรายการเดียว นับแต่ละ tag หนึ่งครั้ง', () {
    final r = run([
      makeEntry(id: '1', mood: 'sad', tags: ['Lab', 'Deadline'], createdAt: DateTime(2026, 10, 20)),
      makeEntry(id: '2', mood: 'neutral', tags: ['Lab'], createdAt: DateTime(2026, 10, 21)),
    ]);
    expect(r.totalEntries, 2);
    expect(r.contextCounts['Lab'], 2);
    expect(r.contextCounts['Deadline'], 1);
  });

  test('tag ซ้ำในรายการเดียว นับครั้งเดียว', () {
    final r = run([
      makeEntry(id: '1', mood: 'sad', tags: ['Lab', 'Lab'], createdAt: DateTime(2026, 10, 20)),
    ]);
    expect(r.contextCounts['Lab'], 1);
  });

  test('ขอบเวลา: weekStart ถูกนับ, weekEnd ไม่ถูกนับ', () {
    final r = run([
      makeEntry(id: '1', mood: 'happy', tags: [], createdAt: weekStart),
      makeEntry(id: '2', mood: 'happy', tags: [], createdAt: weekEnd),
    ]);
    expect(r.totalEntries, 1);
  });

  test('รายการนอกสัปดาห์ไม่ถูกนับ', () {
    final r = run([
      makeEntry(id: '1', mood: 'angry', tags: ['Lab'], createdAt: DateTime(2026, 10, 10)),
      makeEntry(id: '2', mood: 'angry', tags: ['Lab'], createdAt: DateTime(2026, 11, 1)),
    ]);
    expect(r.totalEntries, 0);
    expect(r.moodCounts, isEmpty);
    expect(r.contextCounts, isEmpty);
  });
}