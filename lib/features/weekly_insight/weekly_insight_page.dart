import 'package:flutter/material.dart';

import '../../models/weekly_insight.dart';
import 'weekly_insight_config.dart';

class WeeklyInsightPage extends StatelessWidget {
  const WeeklyInsightPage({super.key, required this.insight});

  final WeeklyInsight insight;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _topMoodText() {
    var maxCount = 0;
    for (final m in weeklyInsightMoods) {
      final c = insight.moodCounts[m] ?? 0;
      if (c > maxCount) maxCount = c;
    }
    return weeklyInsightMoods
        .where((m) => (insight.moodCounts[m] ?? 0) == maxCount)
        .map((m) => weeklyInsightMoodLabels[m]!)
        .join(' / ');
  }

  /// เรียงจากบ่อยที่สุด ถ้าเท่ากันให้ตามลำดับในรายการกลาง
  List<String> _sortedTags() {
    final tags = [...weeklyInsightContextTags];
    tags.sort((a, b) {
      final diff =
          (insight.contextCounts[b] ?? 0) - (insight.contextCounts[a] ?? 0);
      if (diff != 0) return diff;
      return weeklyInsightContextTags.indexOf(a) -
          weeklyInsightContextTags.indexOf(b);
    });
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    // weekEnd ไม่รวมในช่วง จึงแสดงวันสุดท้ายเป็น weekEnd ลบ 1 วัน
    final lastDay = DateTime(
      insight.weekEnd.year,
      insight.weekEnd.month,
      insight.weekEnd.day - 1,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('สรุป 7 วันล่าสุด')),
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
                                                if (insight.totalEntries < weeklyInsightMinEntries) ...[
                          const SizedBox(height: 8),
                          Text(
                            'ข้อมูลยังไม่เพียงพอ (มี ${insight.totalEntries} '
                            'จากอย่างน้อย $weeklyInsightMinEntries รายการ) '
                            'ภาพรวมนี้อาจยังไม่สะท้อนแนวโน้มจริง',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CountSection(
                  title: 'อารมณ์ใน 7 วันล่าสุด',
                  keys: weeklyInsightMoods,
                  labels: weeklyInsightMoodLabels,
                  counts: insight.moodCounts,
                ),
                const SizedBox(height: 16),
                _CountSection(
                  title: 'บริบทที่พบบ่อย (เรียงจากบ่อยที่สุด)',
                  keys: _sortedTags(),
                  labels: {for (final t in weeklyInsightContextTags) t: t},
                  counts: insight.contextCounts,
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
          'ยังไม่มีบันทึกใน 7 วันล่าสุด',
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
  });

  final String title;
  final List<String> keys;
  final Map<String, String> labels;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    // แท่งเทียบกับค่ามากสุดในกลุ่มนี้ ทำให้เห็นความต่างชัดแม้มีบันทึกเยอะ
    final maxCount = keys
        .map((k) => counts[k] ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);

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
                maxCount: maxCount,
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
    required this.maxCount,
  });

  final String label;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final value = maxCount == 0 ? 0.0 : count / maxCount;
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