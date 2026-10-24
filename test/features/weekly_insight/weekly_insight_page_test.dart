import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    await tester.pumpWidget(MaterialApp(home: WeeklyInsightPage(insight: empty)));

    expect(find.text('ยังไม่มีบันทึกในสัปดาห์นี้'), findsOneWidget);
  });

  testWidgets('แสดงข้อมูลสรุปเมื่อมีบันทึก', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.text('บันทึกทั้งหมด 6 ครั้ง'), findsOneWidget);
    expect(find.text('Deadline'), findsOneWidget);
  });

  testWidgets('แสดงช่วงวันที่ โดยวันสุดท้ายคือ weekEnd ลบ 1 วัน', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.text('19/10/2026 - 25/10/2026'), findsOneWidget);
  });

  testWidgets('tag เรียงจากบ่อยที่สุด และเท่ากันเรียงตามรายการกลาง', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    // Deadline (3 ครั้ง) ต้องอยู่บนสุด
    expect(top('Deadline'), lessThan(top('Coding')));
    // ที่เหลือเท่ากันที่ 1 ครั้ง เรียงตามรายการกลาง
    expect(top('Coding'), lessThan(top('Lab')));
    expect(top('Lab'), lessThan(top('Project')));
    expect(top('Project'), lessThan(top('Group Work')));
    expect(top('Group Work'), lessThan(top('Presentation')));
    expect(top('Presentation'), lessThan(top('Personal')));
  });

  testWidgets('แสดงข้อความกำกับว่าไม่ใช่การวินิจฉัย', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.textContaining('ไม่ใช่การวินิจฉัย'), findsOneWidget);
  });
}