import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_mock_data.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_page.dart';
import 'package:moodmate/models/weekly_insight.dart';

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
    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightPage(insight: buildMockWeeklyInsight())),
    );

    expect(find.text('บันทึกทั้งหมด 6 ครั้ง'), findsOneWidget);
    expect(find.text('Deadline'), findsOneWidget);
  });
}