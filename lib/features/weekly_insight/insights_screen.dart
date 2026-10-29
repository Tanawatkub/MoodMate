import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/constants/moodmate_mood_style.dart';
import '../../models/weekly_insight.dart';
import '../../services/reflection_service.dart';
import 'weekly_insight_calculator.dart';
import 'weekly_insight_config.dart';

enum _InsightRange {
  sevenDays(7, '7 วันที่ผ่านมา'),
  thirtyDays(30, '30 วันที่ผ่านมา'),
  ninetyDays(90, '3 เดือนล่าสุด');

  const _InsightRange(this.days, this.label);
  final int days;
  final String label;
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  static const _ink = Color(0xFF33302D);
  static const _muted = Color(0xFF817B75);
  static const _accent = Color(0xFFC48E66);
  static const _moodColors = <String, Color>{
    'happy': Color(0xFF5B9B70),
    'angry': Color(0xFFC77C62),
    'sad': Color(0xFF8B78B4),
    'neutral': Color(0xFFD1A94A),
  };

  _InsightRange _selectedRange = _InsightRange.sevenDays;
  late Future<WeeklyInsight> _insightFuture;
  final Map<String, Future<String>> _summaryFutures = {};

  @override
  void initState() {
    super.initState();
    _insightFuture = _loadInsight(_selectedRange);
  }

  Future<WeeklyInsight> _loadInsight(_InsightRange range) async {
    final userId = widget.dependencies.auth.currentUserId;
    if (userId == null) {
      throw StateError('ไม่พบผู้ใช้ที่เข้าสู่ระบบ');
    }
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day + 1);
    final rangeStart = DateTime(now.year, now.month, now.day - range.days + 1);
    final createdAt = widget.dependencies.auth.currentUserCreatedAt?.toLocal();
    final accountStart = createdAt == null
        ? rangeStart
        : DateTime(createdAt.year, createdAt.month, createdAt.day);
    final start = accountStart.isAfter(rangeStart) ? accountStart : rangeStart;
    final entries = await widget.dependencies.diary.getEntries(
      userId: userId,
      from: start,
      to: end,
    );
    return WeeklyInsightCalculator().calculate(
      entries: entries,
      weekStart: start,
      weekEnd: end,
    );
  }

  void _selectRange(_InsightRange range) {
    setState(() {
      _selectedRange = range;
      _insightFuture = _loadInsight(range);
    });
  }

  void _showRangeSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'เลือกช่วงเวลาสถิติ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final range in _InsightRange.values)
              ListTile(
                title: Text(range.label),
                trailing: range == _selectedRange
                    ? const Icon(Icons.check, color: _accent)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _selectRange(range);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _retryInsight() {
    setState(() => _insightFuture = _loadInsight(_selectedRange));
  }

  Future<void> _refresh() async {
    final future = _loadInsight(_selectedRange);
    setState(() => _insightFuture = future);
    await future;
  }

  String _summaryKey(WeeklyInsight insight) {
    final moods = insight.moodCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final contexts = insight.contextCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return '${insight.weekStart.toIso8601String()}|'
        '${insight.weekEnd.toIso8601String()}|${insight.totalEntries}|'
        '${moods.map((entry) => '${entry.key}:${entry.value}').join(',')}|'
        '${contexts.map((entry) => '${entry.key}:${entry.value}').join(',')}';
  }

  Future<String> _summaryFor(WeeklyInsight insight) {
    final key = _summaryKey(insight);
    return _summaryFutures.putIfAbsent(
      key,
      () => widget.dependencies.reflection.summarizeInsight(insight: insight),
    );
  }

  void _retrySummary(WeeklyInsight insight) {
    setState(() {
      _summaryFutures.remove(_summaryKey(insight));
    });
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _rangeTitle(WeeklyInsight insight) {
    final lastDay = DateTime(
      insight.weekEnd.year,
      insight.weekEnd.month,
      insight.weekEnd.day - 1,
    );
    return 'ช่วงวันที่ ${_formatDate(insight.weekStart)} - ${_formatDate(lastDay)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('สถิติ'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'เลือกช่วงเวลา',
            icon: const Icon(Icons.tune),
            onPressed: _showRangeSelector,
          ),
        ],
      ),
      body: FutureBuilder<WeeklyInsight>(
        future: _insightFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'โหลดสถิติไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่อแล้วลองใหม่',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retryInsight,
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            );
          }

          final insight = snapshot.data!;
          final topMood = _topMood(insight);
          final tags = [...weeklyInsightContextTags]
            ..sort((a, b) {
              final difference =
                  (insight.contextCounts[b] ?? 0) -
                  (insight.contextCounts[a] ?? 0);
              return difference == 0
                  ? weeklyInsightContextTags.indexOf(a) -
                        weeklyInsightContextTags.indexOf(b)
                  : difference;
            });

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ภาพรวมรายช่วง',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _showRangeSelector,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedRange.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _rangeTitle(insight),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _OverviewCard(
                  insight: insight,
                  topMood: topMood,
                  moodColors: _moodColors,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ปัจจัยหลัก',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'บันทึก ${insight.totalEntries} ครั้ง',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ContextTags(tags: tags, counts: insight.contextCounts),
                const SizedBox(height: 18),
                _AiSummaryCard(
                  insight: insight,
                  future: _summaryFor(insight),
                  onRetry: () => _retrySummary(insight),
                ),
                const SizedBox(height: 16),
                Text(
                  'สรุปนี้อ้างอิงจากจำนวนอารมณ์และบริบทที่บันทึก '
                  'ไม่ได้ยืนยันสาเหตุหรือวินิจฉัยสุขภาพ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _muted, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _topMood(WeeklyInsight insight) {
    String? top;
    for (final mood in weeklyInsightMoods) {
      if ((insight.moodCounts[mood] ?? 0) >
          (top == null ? 0 : insight.moodCounts[top] ?? 0)) {
        top = mood;
      }
    }
    return top;
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.insight,
    required this.topMood,
    required this.moodColors,
  });

  final WeeklyInsight insight;
  final String? topMood;
  final Map<String, Color> moodColors;

  static const _moodIcons = <String, IconData>{
    'happy': Icons.sentiment_satisfied_alt,
    'angry': Icons.sentiment_very_dissatisfied,
    'sad': Icons.sentiment_dissatisfied,
    'neutral': Icons.sentiment_neutral,
  };

  @override
  Widget build(BuildContext context) {
    final topCount = topMood == null ? 0 : insight.moodCounts[topMood] ?? 0;
    final percentage = insight.totalEntries == 0
        ? 0
        : (topCount * 100 / insight.totalEntries).round();

    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x1A33302D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'อารมณ์หลัก',
                    style: TextStyle(fontSize: 12, color: Color(0xFF817B75)),
                  ),
                ),
                if (insight.totalEntries > 0)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF0D8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        '$percentage% ของบันทึก',
                        style: const TextStyle(
                          color: Color(0xFF8D6D2E),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            CircleAvatar(
              radius: 38,
              backgroundColor: topMood == null
                  ? const Color(0xFFF7ECCD)
                  : MoodMateMoodStyle.backgroundColorFor(topMood!),
              child: Icon(
                _moodIcons[topMood] ?? Icons.spa_outlined,
                color: MoodMateMoodStyle.foregroundColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              topMood == null
                  ? 'ยังไม่มีบันทึกในช่วงนี้'
                  : 'อารมณ์ที่พบบ่อย: ${weeklyInsightMoodLabels[topMood]}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF33302D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              insight.totalEntries == 0
                  ? 'เริ่มเช็กอินเพื่อดูแนวโน้มอารมณ์ของคุณ'
                  : 'จากบันทึก ${insight.totalEntries} ครั้งในช่วงนี้',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF817B75),
                fontSize: 11,
                height: 1.5,
              ),
            ),
            if (insight.totalEntries < weeklyInsightMinEntries) ...[
              const SizedBox(height: 4),
              Text(
                'แนวโน้มอาจเปลี่ยนแปลงได้เมื่อมีข้อมูลเพิ่ม',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.brown.shade400, fontSize: 10),
              ),
            ],
            const SizedBox(height: 16),
            _MoodDistribution(insight: insight, moodColors: moodColors),
          ],
        ),
      ),
    );
  }
}

class _MoodDistribution extends StatelessWidget {
  const _MoodDistribution({required this.insight, required this.moodColors});

  final WeeklyInsight insight;
  final Map<String, Color> moodColors;

  @override
  Widget build(BuildContext context) {
    final activeMoods = weeklyInsightMoods
        .where((mood) => (insight.moodCounts[mood] ?? 0) > 0)
        .toList(growable: false);

    if (activeMoods.isEmpty) {
      return const Divider(color: Color(0xFFF0ECE5), height: 1);
    }

    return Column(
      children: [
        Row(
          children: [
            for (final mood in activeMoods)
              Expanded(
                flex: insight.moodCounts[mood] ?? 1,
                child: Container(
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: moodColors[mood],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            for (final mood in activeMoods)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: moodColors[mood],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${weeklyInsightMoodLabels[mood]} ${insight.moodCounts[mood]}',
                    style: const TextStyle(
                      color: Color(0xFF69635D),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ContextTags extends StatelessWidget {
  const _ContextTags({required this.tags, required this.counts});

  final List<String> tags;
  final Map<String, int> counts;

  static const _tagColors = [
    Color(0xFFE9F0E7),
    Color(0xFFF9E8DE),
    Color(0xFFE8EDF4),
    Color(0xFFF7EFD8),
    Color(0xFFEDE8F3),
    Color(0xFFE5F0EE),
    Color(0xFFF2E9E2),
  ];

  @override
  Widget build(BuildContext context) {
    final activeTags = tags.where((tag) => (counts[tag] ?? 0) > 0).toList();
    if (activeTags.isEmpty) {
      return const Text(
        'ยังไม่มีบริบทที่บันทึกในช่วงนี้',
        style: TextStyle(color: Color(0xFF817B75), fontSize: 12),
      );
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (var i = 0; i < activeTags.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              color: _tagColors[i % _tagColors.length],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              child: Text(
                '${activeTags[i]}  ${counts[activeTags[i]]} ครั้ง',
                style: const TextStyle(
                  color: Color(0xFF4F4A44),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({
    required this.insight,
    required this.future,
    required this.onRetry,
  });

  final WeeklyInsight insight;
  final Future<String> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x1A33302D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFFAF0D8),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF9D7742),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'บทสรุปจาก AI',
                    style: TextStyle(
                      color: Color(0xFF33302D),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  insight.totalEntries == 0 ? 'รอข้อมูล' : 'อัปเดตอัตโนมัติ',
                  style: const TextStyle(color: Color(0xFF817B75), fontSize: 9),
                ),
              ],
            ),
            const SizedBox(height: 13),
            FutureBuilder<String>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'กำลังสรุปแนวโน้มจากสถิติของคุณ...',
                          style: TextStyle(
                            color: Color(0xFF817B75),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  final error = snapshot.error;
                  final message = error is InsightSummaryException
                      ? error.message
                      : 'สร้างสรุป AI ไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองใหม่';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF746D66),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('ลองใหม่'),
                        ),
                      ),
                    ],
                  );
                }

                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Color(0xFF514B45),
                    fontSize: 12,
                    height: 1.7,
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Divider(height: 1, color: Color(0xFFF0ECE5)),
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 13,
                  color: Color(0xFF6A9A72),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'วิเคราะห์จากจำนวนอารมณ์และบริบทเท่านั้น',
                    style: TextStyle(color: Color(0xFF817B75), fontSize: 9),
                  ),
                ),
                Icon(Icons.lock_outline, size: 12, color: Color(0xFF9A938C)),
                SizedBox(width: 3),
                Text(
                  'ไม่ส่งเนื้อหาไดอารี่',
                  style: TextStyle(color: Color(0xFF817B75), fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
