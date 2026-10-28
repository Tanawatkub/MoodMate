class WeeklyInsight {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalEntries;
  final Map<String, int> moodCounts;
  final Map<String, int> contextCounts;

  const WeeklyInsight({
    required this.weekStart,
    required this.weekEnd,
    required this.totalEntries,
    required this.moodCounts,
    required this.contextCounts,
  });
}