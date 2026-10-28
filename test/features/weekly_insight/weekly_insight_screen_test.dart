import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_mock_data.dart';
import 'package:moodmate/features/weekly_insight/weekly_insight_screen.dart';
import 'package:moodmate/models/weekly_insight.dart';

void main() {
  testWidgets('แสดง loading ระหว่างรอ แล้วแสดงข้อมูลเมื่อโหลดเสร็จ', (tester) async {
    final completer = Completer<WeeklyInsight>();

    await tester.pumpWidget(
      MaterialApp(
        home: WeeklyInsightScreen(loadInsight: () => completer.future),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(buildMockWeeklyInsight());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('บันทึกทั้งหมด 6 ครั้ง'), findsOneWidget);
  });

  testWidgets('โหลดไม่สำเร็จ แสดงข้อความและไม่เผยรายละเอียด error', (tester) async {
    Future<WeeklyInsight> failing() async => throw Exception('secret-detail');

    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightScreen(loadInsight: failing)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('โหลดสรุปรายสัปดาห์ไม่สำเร็จ'), findsOneWidget);
    expect(find.text('ลองใหม่'), findsOneWidget);
    expect(find.textContaining('secret-detail'), findsNothing);
  });

  testWidgets('กดลองใหม่แล้วโหลดสำเร็จ', (tester) async {
    var calls = 0;
    Future<WeeklyInsight> flaky() async {
      calls++;
      if (calls == 1) throw Exception('network');
      return buildMockWeeklyInsight();
    }

    await tester.pumpWidget(
      MaterialApp(home: WeeklyInsightScreen(loadInsight: flaky)),
    );
    await tester.pumpAndSettle();
    expect(find.text('ลองใหม่'), findsOneWidget);

    await tester.tap(find.text('ลองใหม่'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('บันทึกทั้งหมด 6 ครั้ง'), findsOneWidget);
  });
}