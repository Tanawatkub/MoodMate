import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/core/constants/moodmate_mood_style.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_mock_data.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_page.dart';
import 'package:moodmate/models/weekly_insight.dart';

/// ขยายจอทดสอบให้สูง เพื่อให้ ListView สร้าง widget ครบทุกส่วน
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('แสดง empty state เมื่อไม่มีบันทึก', (tester) async {
    final empty = WeeklyInsight(
      weekStart: DateTime(2026, 10, 19),
      weekEnd: DateTime(2026, 10, 26),
      totalEntries: 0,
      moodCounts: const {},
      contextCounts: const {},
    );

    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: empty)),
    );

    expect(find.text('ยังไม่มีบันทึกใน 7 วันล่าสุด'), findsOneWidget);
  });

  testWidgets('แสดงข้อมูลสรุปเมื่อมีบันทึก', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.text('บันทึกทั้งหมด 6 ครั้ง'), findsOneWidget);
    expect(find.text('เดดไลน์'), findsOneWidget);
  });

  testWidgets('แสดงช่วงวันที่ โดยวันสุดท้ายคือ weekEnd ลบ 1 วัน', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.text('19/10/2026 - 25/10/2026'), findsOneWidget);
  });

  testWidgets('tag เรียงจากบ่อยที่สุด และเท่ากันเรียงตามรายการกลาง', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    // เดดไลน์ (3 ครั้ง) ต้องอยู่บนสุด
    expect(top('เดดไลน์'), lessThan(top('โค้ดดิ้ง')));
    // ที่เหลือเท่ากันที่ 1 ครั้ง เรียงตามรายการกลาง
    expect(top('โค้ดดิ้ง'), lessThan(top('แล็บ')));
    expect(top('แล็บ'), lessThan(top('โปรเจกต์')));
    expect(top('โปรเจกต์'), lessThan(top('งานกลุ่ม')));
    expect(top('งานกลุ่ม'), lessThan(top('พรีเซนต์')));
    expect(top('พรีเซนต์'), lessThan(top('เรื่องส่วนตัว')));
  });

  testWidgets('แท่งสถิติใช้อารมณ์ตรงกับสีมาตรฐานทุกหน้า', (tester) async {
    useTallScreen(tester);
    final insight = WeeklyInsight(
      weekStart: DateTime(2026, 10, 19),
      weekEnd: DateTime(2026, 10, 26),
      totalEntries: 4,
      moodCounts: const {'happy': 1, 'angry': 1, 'sad': 1, 'neutral': 1},
      contextCounts: const {},
    );

    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: insight)),
    );

    final moodBars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .take(4)
        .map((bar) => bar.color)
        .toList();
    expect(moodBars, [
      MoodMateMoodStyle.backgroundColorFor('happy'),
      MoodMateMoodStyle.backgroundColorFor('angry'),
      MoodMateMoodStyle.backgroundColorFor('sad'),
      MoodMateMoodStyle.backgroundColorFor('neutral'),
    ]);
  });

  testWidgets('แสดงข้อความกำกับว่าไม่ใช่การวินิจฉัย', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.textContaining('ไม่ใช่การวินิจฉัย'), findsOneWidget);
  });
}
