import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selawathub/core/services/counter_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';

/// Stats data model for the stats page.
class StatsData {
  final List<DayData> heatmapData;
  final AllTimeBreakdown allTimeBreakdown;
  final List<Map<String, dynamic>> weeklyData;
  final int currentStreak;
  final int bestStreak;
  final int daysActive;
  final int todayTotal;
  final bool hasData;

  const StatsData({
    this.heatmapData = const [],
    this.allTimeBreakdown = const AllTimeBreakdown(),
    this.weeklyData = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.daysActive = 0,
    this.todayTotal = 0,
    this.hasData = false,
  });
}

class DayData {
  final int selawat;
  final int zikir;
  final List<(String name, String category, int count)> topDhikr;

  const DayData({
    this.selawat = 0,
    this.zikir = 0,
    this.topDhikr = const [],
  });

  int get total => selawat + zikir;

  int get level {
    if (total == 0) return 0;
    if (total < 200) return 1;
    if (total < 600) return 2;
    if (total < 1200) return 3;
    return 4;
  }
}

class AllTimeBreakdown {
  final int selawat;
  final int zikir;
  final List<(String, String, int)> top;

  const AllTimeBreakdown({
    this.selawat = 0,
    this.zikir = 0,
    this.top = const [],
  });
}

final statsProvider = FutureProvider<StatsData>((ref) async {
  if (!SupabaseService.isAuthenticated) {
    return const StatsData();
  }

  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 363));
  final sessions =
      await CounterService.getSessionsInRange(start: start, end: now);

  if (sessions.isEmpty) return const StatsData();

  // Build day map
  final dayMap = <String, Map<String, dynamic>>{};
  for (final s in sessions) {
    final date = s['date'] as String;
    final cat = s['category'] as String;
    final count = (s['count'] as int?) ?? 0;
    final dhikrId = s['dhikr_id'] as String;

    dayMap.putIfAbsent(
        date, () => {'selawat': 0, 'zikir': 0, 'dhikr': <String, (String, int)>{}});
    dayMap[date]![cat] = (dayMap[date]![cat] as int) + count;
    final dhikrMap = dayMap[date]!['dhikr'] as Map<String, (String, int)>;
    final prev = dhikrMap[dhikrId];
    dhikrMap[dhikrId] = (cat, (prev?.$2 ?? 0) + count);
  }

  // Build heatmap (364 days)
  final heatmapData = <DayData>[];
  int totalSel = 0, totalZik = 0;
  final allDhikr = <String, (String, int)>{};
  final activeDates = <String>{};

  for (int i = 0; i < 364; i++) {
    final d = start.add(Duration(days: i));
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final day = dayMap[key];
    if (day != null) {
      final sel = day['selawat'] as int;
      final zik = day['zikir'] as int;
      totalSel += sel;
      totalZik += zik;
      activeDates.add(key);

      final dhikrMap = day['dhikr'] as Map<String, (String, int)>;
      final topDhikr = dhikrMap.entries
          .map((e) => (e.key, e.value.$1, e.value.$2))
          .toList()
        ..sort((a, b) => b.$3.compareTo(a.$3));

      for (final e in dhikrMap.entries) {
        final prev = allDhikr[e.key];
        allDhikr[e.key] = (e.value.$1, (prev?.$2 ?? 0) + e.value.$2);
      }

      heatmapData.add(DayData(selawat: sel, zikir: zik, topDhikr: topDhikr));
    } else {
      heatmapData.add(const DayData());
    }
  }

  // Compute streaks
  int currentStreak = 0, bestStreak = 0, tempStreak = 0;
  for (int i = 363; i >= 0; i--) {
    final d = start.add(Duration(days: i));
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (activeDates.contains(key)) {
      tempStreak++;
      if (tempStreak > bestStreak) bestStreak = tempStreak;
    } else {
      tempStreak = 0;
    }
  }
  // Current streak from today backwards
  for (int i = 0; i < 364; i++) {
    final d = now.subtract(Duration(days: i));
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (activeDates.contains(key)) {
      currentStreak++;
    } else if (i > 0) {
      break;
    }
  }

  // Today total
  final todayKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final todayData = dayMap[todayKey];
  final todayTotal = ((todayData?['selawat'] as int?) ?? 0) +
      ((todayData?['zikir'] as int?) ?? 0);

  // All-time top dhikr
  final topList = allDhikr.entries
      .map((e) => (e.key, e.value.$1, e.value.$2))
      .toList()
    ..sort((a, b) => b.$3.compareTo(a.$3));

  // Weekly data
  final weeklyData = await CounterService.getWeeklyBreakdown();

  return StatsData(
    heatmapData: heatmapData,
    allTimeBreakdown: AllTimeBreakdown(
        selawat: totalSel, zikir: totalZik, top: topList.take(7).toList()),
    weeklyData: weeklyData,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    daysActive: activeDates.length,
    todayTotal: todayTotal,
    hasData: heatmapData.any((d) => d.total > 0),
  );
});
