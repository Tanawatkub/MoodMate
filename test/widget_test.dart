import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/main.dart';

void main() {
  testWidgets('MoodMate App smoke test', (WidgetTester tester) async {
    // เปลี่ยน MoodMateApp ให้ตรงกับชื่อคลาสหลักใน main.dart ของคุณ
    await tester.pumpWidget(const MoodMateApp());

    // ตรวจสอบเบื้องต้น
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}