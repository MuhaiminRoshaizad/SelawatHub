/// Shared streak computation used by both the Stats page and the Profile page.
///
/// A "streak day" is a calendar day on which the user's combined dhikr total
/// meets or exceeds the configured daily goal (or at least 1 count when the
/// goal is 0).
///
/// TikTok-style behaviour:
///  • If today's requirement is met → fire is ON, streak count includes today.
///  • If today's requirement is NOT met yet → fire is OFF, streak count shows
///    the run of consecutive qualifying days ending yesterday. The streak is
///    only lost when the day rolls over without today qualifying.
class StreakResult {
  final int days;
  final bool todayMet;
  const StreakResult({required this.days, required this.todayMet});

  bool get fireOn => todayMet;
}

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

StreakResult computeStreak({
  required Map<String, int> dailyTotals,
  required int dailyGoal,
  required DateTime today,
}) {
  final threshold = dailyGoal > 0 ? dailyGoal : 1;
  bool meets(DateTime d) => (dailyTotals[_key(d)] ?? 0) >= threshold;

  final todayDate = DateTime(today.year, today.month, today.day);
  final todayMet = meets(todayDate);

  var cursor = todayMet ? todayDate : todayDate.subtract(const Duration(days: 1));
  int days = 0;
  for (int i = 0; i < 365; i++) {
    if (meets(cursor)) {
      days++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return StreakResult(days: days, todayMet: todayMet);
}

/// Walks the full date range to compute the longest streak ever recorded
/// using the same threshold rule.
int computeBestStreak({
  required Map<String, int> dailyTotals,
  required int dailyGoal,
}) {
  if (dailyTotals.isEmpty) return 0;
  final threshold = dailyGoal > 0 ? dailyGoal : 1;
  final keys = dailyTotals.keys.toList()..sort();
  int best = 0, run = 0;
  DateTime? prev;
  for (final k in keys) {
    final parts = k.split('-').map(int.parse).toList();
    final d = DateTime(parts[0], parts[1], parts[2]);
    final qualifies = (dailyTotals[k] ?? 0) >= threshold;
    if (!qualifies) {
      run = 0;
      prev = d;
      continue;
    }
    if (prev != null && d.difference(prev).inDays == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > best) best = run;
    prev = d;
  }
  return best;
}
