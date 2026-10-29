import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_config.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_page.dart';
import 'package:moodmate/models/weekly_insight.dart';

WeeklyInsight insightWith(int total) {
  return WeeklyInsight(
    weekStart: DateTime(2026, 10, 19),
    weekEnd: DateTime(2026, 10, 26),
    totalEntries: total,
    moodCounts: {'happy': total},
    contextCounts: const {},
  );
}

Future<void> pumpPage(WidgetTester tester, WeeklyInsight insight) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: WeeklyInsightPage(insight: insight)));
}

void main() {
  testWidgets('ข้อมูลน้อยกว่าเกณฑ์ แสดงข้อความข้อมูลไม่เพียงพอ', (tester) async {
    await pumpPage(tester, insightWith(weeklyInsightMinEntries - 1));
    expect(find.textContaining('ข้อมูลยังไม่เพียงพอ'), findsOneWidget);
  });

  testWidgets('ข้อมูลเท่ากับเกณฑ์พอดี ไม่แสดงข้อความเตือน', (tester) async {
    await pumpPage(tester, insightWith(weeklyInsightMinEntries));
    expect(find.textContaining('ข้อมูลยังไม่เพียงพอ'), findsNothing);
  });

  testWidgets('ไม่มีบันทึกเลย แสดง empty state ไม่ใช่ข้อความเตือน', (tester) async {
    await pumpPage(tester, insightWith(0));
    expect(find.text('ยังไม่มีบันทึกใน 7 วันล่าสุด'), findsOneWidget);
    expect(find.textContaining('ข้อมูลยังไม่เพียงพอ'), findsNothing);
  });
}