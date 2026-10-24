import 'package:flutter/material.dart';

import '../../models/weekly_insight.dart';

// TODO: เปลี่ยนไปใช้ค่ากลางจาก moodmate_constants.dart เมื่อไฟล์นั้นมีแล้ว
const _moodOrder = ['happy', 'angry', 'sad', 'neutral'];
const _moodLabels = {
  'happy': 'ยิ้ม',
  'angry': 'โกรธ',
  'sad': 'เศร้า',
  'neutral': 'เฉย ๆ',
};
const _tagOrder = [
  'Coding',
  'Lab',
  'Project',
  'Group Work',
  'Presentation',
  'Deadline',
  'Personal',
];

class WeeklyInsightPage extends StatelessWidget {
  const WeeklyInsightPage({super.key, required this.insight});

  final WeeklyInsight insight;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _topMoodText() {
    var maxCount = 0;
    for (final m in _moodOrder) {
      final c = insight.moodCounts[m] ?? 0;
      if (c > maxCount) maxCount = c;
    }
    final tops = _moodOrder
        .where((m) => (insight.moodCounts[m] ?? 0) == maxCount)
        .map((m) => _moodLabels[m]!)
        .join(' / ');
    return tops;
  }

  @override
  Widget build(BuildContext context) {
    // weekEnd ไม่รวมในช่วง จึงแสดงวันสุดท้ายเป็น weekEnd ลบ 1 วัน
    final lastDay = insight.weekEnd.subtract(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปรายสัปดาห์')),
      body: insight.totalEntries == 0
          ? const _EmptyView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_formatDate(insight.weekStart)} - ${_formatDate(lastDay)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('บันทึกทั้งหมด ${insight.totalEntries} ครั้ง'),
                        const SizedBox(height: 4),
                        Text('อารมณ์ที่บันทึกบ่อยที่สุด: ${_topMoodText()}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CountSection(
                  title: 'อารมณ์ในสัปดาห์นี้',
                  keys: _moodOrder,
                  labels: _moodLabels,
                  counts: insight.moodCounts,
                  total: insight.totalEntries,
                ),
                const SizedBox(height: 16),
                _CountSection(
                  title: 'บริบทที่พบบ่อย',
                  keys: _tagOrder,
                  labels: {for (final t in _tagOrder) t: t},
                  counts: insight.contextCounts,
                  total: insight.totalEntries,
                ),
                const SizedBox(height: 16),
                Text(
                  'สรุปนี้แสดงความถี่จากสิ่งที่คุณบันทึกไว้เท่านั้น '
                  'ไม่ใช่การวินิจฉัยหรือการยืนยันสาเหตุของความรู้สึก',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'ยังไม่มีบันทึกในสัปดาห์นี้',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CountSection extends StatelessWidget {
  const _CountSection({
    required this.title,
    required this.keys,
    required this.labels,
    required this.counts,
    required this.total,
  });

  final String title;
  final List<String> keys;
  final Map<String, String> labels;
  final Map<String, int> counts;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final key in keys) ...[
              _BarRow(
                label: labels[key] ?? key,
                count: counts[key] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: value, minHeight: 10),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text('$count', textAlign: TextAlign.end),
        ),
      ],
    );
  }
}