import 'package:flutter/material.dart';

import '../../models/weekly_insight.dart';
import 'weekly_insight_page.dart';

class WeeklyInsightScreen extends StatefulWidget {
  const WeeklyInsightScreen({super.key, required this.loadInsight});

  /// ฟังก์ชันที่คืนสรุปรายสัปดาห์ (ภายหลังจะเรียก DiaryRepository + Calculator)
  final Future<WeeklyInsight> Function() loadInsight;

  @override
  State<WeeklyInsightScreen> createState() => _WeeklyInsightScreenState();
}

class _WeeklyInsightScreenState extends State<WeeklyInsightScreen> {
  late Future<WeeklyInsight> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadInsight();
  }

  void _retry() {
    setState(() {
      _future = widget.loadInsight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeeklyInsight>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('สรุปรายสัปดาห์')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          // ไม่แสดงรายละเอียด error ให้ผู้ใช้ และไม่ log ข้อมูล diary
          return Scaffold(
            appBar: AppBar(title: const Text('สรุปรายสัปดาห์')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'โหลดสรุปรายสัปดาห์ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return WeeklyInsightPage(insight: snapshot.data!);
      },
    );
  }
}