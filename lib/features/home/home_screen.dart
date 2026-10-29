import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/constants/moodmate_constants.dart';
import '../../core/constants/moodmate_mood_style.dart';
import '../../models/mood_entry.dart';
import '../../repositories/synced_diary_repository.dart';
import '../check_in/new_check_in_screen.dart';
import '../diary/diary_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../weekly_insight/weekly_insight_calculator.dart';
import '../weekly_insight/weekly_insight_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MoodEntry>> _entriesFuture;
  StreamSubscription<void>? _diaryChangesSubscription;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
    final diary = widget.dependencies.diary;
    if (diary is SyncedDiaryRepository) {
      _diaryChangesSubscription = diary.changes.listen((_) {
        if (mounted) _reload();
      });
    }
  }

  @override
  void dispose() {
    _diaryChangesSubscription?.cancel();
    super.dispose();
  }

  Future<List<MoodEntry>> _loadEntries() async {
    final userId = widget.dependencies.auth.currentUserId;
    if (userId == null) {
      throw StateError('ไม่พบผู้ใช้ที่เข้าสู่ระบบ');
    }
    final now = DateTime.now();
    final recentStart = DateTime(now.year, now.month, now.day - 29);
    final createdAt = widget.dependencies.auth.currentUserCreatedAt;
    final accountStart = createdAt == null
        ? recentStart
        : DateTime(createdAt.year, createdAt.month, createdAt.day);
    final from = accountStart.isAfter(recentStart) ? accountStart : recentStart;
    final to = DateTime(now.year, now.month, now.day + 1);
    return widget.dependencies.diary.getEntries(
      userId: userId,
      from: from,
      to: to,
    );
  }

  void _reload() {
    setState(() => _entriesFuture = _loadEntries());
  }

  Future<void> _refresh() async {
    final future = _loadEntries();
    setState(() => _entriesFuture = future);
    await future;
  }

  String _dateKey(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month}-${local.day}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _dayLabel(DateTime date) {
    const days = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return days[date.weekday - 1];
  }

  String _moodLabel(String mood) => MoodMateConstants.moodLabels[mood] ?? mood;

  IconData _moodIcon(String mood) {
    switch (mood) {
      case 'happy':
        return Icons.sentiment_satisfied_alt;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Future<void> _openNewCheckIn() async {
    final saved = await Navigator.push<MoodEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => NewCheckInScreen(dependencies: widget.dependencies),
      ),
    );
    if (saved == null || !mounted) return;
    setState(() {
      _entriesFuture = _entriesFuture.then((entries) {
        final savedDateKey = _dateKey(saved.createdAt);
        final updated =
            entries
                .where((entry) => _dateKey(entry.createdAt) != savedDateKey)
                .toList()
              ..add(saved)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return updated;
      });
    });
  }

  Future<void> _openEntry(MoodEntry entry) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DiaryDetailScreen(dependencies: widget.dependencies, entry: entry),
      ),
    );
    if (deleted != true || !mounted) return;
    setState(() {
      _entriesFuture = _entriesFuture.then(
        (entries) =>
            entries.where((candidate) => candidate.id != entry.id).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - 6);
    final weekEnd = DateTime(now.year, now.month, now.day + 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MoodMate',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'โปรไฟล์',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(dependencies: widget.dependencies),
              ),
            ),
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF222222),
              child: Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<MoodEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'โหลดบันทึกไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่อแล้วลองใหม่',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            );
          }

          final entries = snapshot.data ?? const <MoodEntry>[];
          final entryByDay = <String, MoodEntry>{};
          for (final entry in entries) {
            entryByDay.putIfAbsent(_dateKey(entry.createdAt), () => entry);
          }
          final insight = WeeklyInsightCalculator().calculate(
            entries: entries,
            weekStart: weekStart,
            weekEnd: weekEnd,
          );
          final topMood = weeklyInsightMoods.fold<String?>(
            null,
            (top, mood) =>
                (insight.moodCounts[mood] ?? 0) >
                    (top == null ? 0 : insight.moodCounts[top] ?? 0)
                ? mood
                : top,
          );
          final recentStart = DateTime(now.year, now.month, now.day - 29);
          final createdAt = widget.dependencies.auth.currentUserCreatedAt;
          final accountStart = createdAt == null
              ? recentStart
              : DateTime(createdAt.year, createdAt.month, createdAt.day);
          final calendarStart = accountStart.isAfter(recentStart)
              ? accountStart
              : recentStart;
          final visibleDayCount = now.difference(calendarStart).inDays + 1;
          final calendarDays = List.generate(
            visibleDayCount,
            (index) => DateTime(
              calendarStart.year,
              calendarStart.month,
              calendarStart.day + index,
            ),
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'บันทึกความรู้สึกอย่างเบามือ',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                    ),
                    Text(
                      'วันนี้ • ${_formatDate(now)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '7 วันล่าสุด',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (insight.totalEntries == 0)
                          const Text('ยังไม่มีบันทึกในช่วง 7 วันล่าสุด')
                        else
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    MoodMateMoodStyle.backgroundColorFor(
                                      topMood ?? 'neutral',
                                    ),
                                child: Icon(
                                  _moodIcon(topMood ?? 'neutral'),
                                  color: MoodMateMoodStyle.foregroundColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'บันทึก ${insight.totalEntries} ครั้ง'
                                  '${topMood == null ? '' : ' • อารมณ์ที่พบบ่อย: ${_moodLabel(topMood)}'}',
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            final day = DateTime(
                              now.year,
                              now.month,
                              now.day - 6 + index,
                            );
                            return Column(
                              children: [
                                Text(_dayLabel(day)),
                                const SizedBox(height: 6),
                                Icon(
                                  entryByDay[_dateKey(day)] == null
                                      ? Icons.circle_outlined
                                      : Icons.circle,
                                  size: 10,
                                  color: const Color(0xFFC48E66),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Text(
                        calendarDays.length < 30
                            ? 'ตั้งแต่สมัครสมาชิก'
                            : '30 วันล่าสุด',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ประวัติการบันทึกของคุณ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  key: const ValueKey('history-calendar'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: calendarDays.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final day = calendarDays[index];
                    final entry = entryByDay[_dateKey(day)];
                    return InkWell(
                      onTap: entry == null ? null : () => _openEntry(entry),
                      borderRadius: BorderRadius.circular(40),
                      child: Column(
                        children: [
                          Expanded(
                            child: CircleAvatar(
                              backgroundColor: entry == null
                                  ? const Color(0xFFEFECE2)
                                  : MoodMateMoodStyle.backgroundColorFor(
                                      entry.mood,
                                    ),
                              child: Icon(
                                entry == null
                                    ? Icons.remove
                                    : _moodIcon(entry.mood),
                                color: MoodMateMoodStyle.foregroundColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(day),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewCheckIn,
        backgroundColor: const Color(0xFF222222),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
