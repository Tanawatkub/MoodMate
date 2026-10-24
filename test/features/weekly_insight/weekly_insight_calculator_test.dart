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

  group('การนับ', () {
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
  });

  group('ขอบเวลา', () {
    test('weekStart ถูกนับ, weekEnd ไม่ถูกนับ', () {
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
  });

  group('Validation', () {
    test('mood ที่ไม่อยู่ในรายการกลาง ถูกข้ามทั้งรายการ', () {
      final r = run([
        makeEntry(id: '1', mood: 'excited', tags: ['Lab'], createdAt: DateTime(2026, 10, 20)),
        makeEntry(id: '2', mood: 'happy', tags: [], createdAt: DateTime(2026, 10, 20)),
      ]);
      expect(r.totalEntries, 1);
      expect(r.moodCounts.containsKey('excited'), isFalse);
      // tag ของรายการที่ถูกข้ามต้องไม่ถูกนับ
      expect(r.contextCounts, isEmpty);
    });

    test('mood ตัวพิมพ์ใหญ่ไม่ตรงรายการกลาง ถูกข้าม', () {
      final r = run([
        makeEntry(id: '1', mood: 'Happy', tags: [], createdAt: DateTime(2026, 10, 20)),
      ]);
      expect(r.totalEntries, 0);
    });

    test('tag ที่ไม่อยู่ในรายการกลาง ถูกเมิน แต่รายการยังถูกนับ', () {
      final r = run([
        makeEntry(id: '1', mood: 'sad', tags: ['Lab', 'Gaming'], createdAt: DateTime(2026, 10, 20)),
      ]);
      expect(r.totalEntries, 1);
      expect(r.contextCounts['Lab'], 1);
      expect(r.contextCounts.containsKey('Gaming'), isFalse);
    });

    test('ผลรวม moodCounts เท่ากับ totalEntries เสมอ', () {
      final r = run([
        makeEntry(id: '1', mood: 'happy', tags: [], createdAt: DateTime(2026, 10, 20)),
        makeEntry(id: '2', mood: 'excited', tags: [], createdAt: DateTime(2026, 10, 20)),
        makeEntry(id: '3', mood: 'sad', tags: ['Gaming'], createdAt: DateTime(2026, 10, 21)),
        makeEntry(id: '4', mood: '', tags: [], createdAt: DateTime(2026, 10, 21)),
      ]);
      final sum = r.moodCounts.values.fold<int>(0, (a, b) => a + b);
      expect(sum, r.totalEntries);
      expect(r.totalEntries, 2);
    });
  });
}