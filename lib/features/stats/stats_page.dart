import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/counter_service.dart';
import 'package:selawathub/core/services/custom_dhikr_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/stats_cache.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';
import 'package:selawathub/features/counter/widgets/today_log_sheet.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_refresh_indicator.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/stats/models/day_data.dart';
import 'package:selawathub/features/stats/stats_utils.dart';
import 'package:selawathub/features/stats/widgets/category_breakdown.dart';
import 'package:selawathub/features/stats/widgets/heatmap.dart';
import 'package:selawathub/features/stats/widgets/streak_card.dart';
import 'package:selawathub/features/stats/widgets/summary_card.dart';
import 'package:selawathub/features/stats/widgets/top_dhikr_list.dart';
import 'package:selawathub/features/stats/widgets/weekly_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.onGoToTasbih});
  final VoidCallback? onGoToTasbih;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int? _selectedHeatmapIdx;
  bool _loading = true;
  bool _hasData = false;

  List<DayData> _heatmapData = [];
  ({int sel, int zik, List<(String, String, int)> top}) _allTimeBreakdown =
      (sel: 0, zik: 0, top: []);
  List<WeekData> _weeklyData = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _daysActive = 0;
  int _todayTotal = 0;
  Map<String, int> _todayCounts = const {};
  int _dailyGoal = SettingsService.dailyGoal;

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadStats();
  }

  /// Populate state from in-memory cache so the first frame shows real
  /// data on repeat visits (tab switches, nav pop). The network call in
  /// [_loadStats] still runs and overrides with fresh numbers.
  void _hydrateFromCache() {
    if (!StatsCache.hasData || !StatsCache.isFreshForToday) return;
    final heatmap = StatsCache.heatmap<DayData>();
    if (heatmap.isEmpty) return;
    _heatmapData = heatmap;
    _weeklyData = StatsCache.weeklyData<WeekData>();
    _todayTotal = StatsCache.totalToday;
    _todayCounts = {
      for (final (id, _, count) in heatmap.last.topDhikr) id: count,
    };
    _hasData = heatmap.any((d) => d.total > 0);
    _loading = false;
  }

  Future<void> _loadStats() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 363));

    List<Map<String, dynamic>> sessions;
    if (SupabaseService.isAuthenticated) {
      sessions = await CounterService.getSessionsInRange(
        start: start,
        end: now,
      );
    } else {
      sessions = SettingsService.getLocalSessionsInRange(
        Dhikr.all.map((d) => d.id).toList(),
        start,
        now,
      );
    }

    // Group sessions by date
    final byDate = <String, List<Map<String, dynamic>>>{};
    for (final s in sessions) {
      final date = s['date'] as String;
      (byDate[date] ??= []).add(s);
    }

    // Build _heatmapData (364 entries, one per day)
    final heatmap = <DayData>[];
    for (int i = 0; i < 364; i++) {
      final d = start.add(Duration(days: i));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final daySessions = byDate[dateStr];
      if (daySessions == null || daySessions.isEmpty) {
        heatmap.add(const DayData(selawat: 0, zikir: 0, topDhikr: []));        continue;
      }
      int sel = 0, zik = 0;
      final dhikrMap = <String, (String, int)>{};
      for (final s in daySessions) {
        final cat = s['category'] as String;
        final count = (s['count'] as int?) ?? 0;
        final dhikrId = s['dhikr_id'] as String;
        if (cat.toLowerCase() == 'selawat') {
          sel += count;
        } else {
          zik += count;
        }
        final prev = dhikrMap[dhikrId];
        dhikrMap[dhikrId] = (cat, (prev?.$2 ?? 0) + count);
      }
      final topDhikr = dhikrMap.entries
          .map((e) => (e.key, e.value.$1, e.value.$2))
          .toList()
        ..sort((a, b) => b.$3.compareTo(a.$3));
      heatmap.add(DayData(selawat: sel, zikir: zik, topDhikr: topDhikr));
    }

    // All-time breakdown
    int totalSel = 0, totalZik = 0;
    final dhikrTotals = <String, (String, int)>{};
    for (final d in heatmap) {
      totalSel += d.selawat;
      totalZik += d.zikir;
      for (final (name, cat, count) in d.topDhikr) {
        final prev = dhikrTotals[name];
        dhikrTotals[name] = (cat, (prev?.$2 ?? 0) + count);
      }
    }
    final topList = dhikrTotals.entries
        .map((e) => (e.key, e.value.$1, e.value.$2))
        .toList()
      ..sort((a, b) => b.$3.compareTo(a.$3));

    // ── Streaks ──
    // Streak is goal-based: a day only counts if the user hit their
    // daily goal. Today is given a grace period — if today's total hasn't
    // reached the goal yet, we don't break the streak (we simply start
    // counting from yesterday). `daysActive` tracks any activity and
    // remains a pure engagement metric.
    final goal = SettingsService.dailyGoal;
    final today = DateTime(now.year, now.month, now.day);

    int current = 0, best = 0, daysActive = 0;

    // Current streak: walk from most recent day backwards.
    int i = heatmap.length - 1;
    if (i >= 0) {
      final lastDate = start.add(Duration(days: i));
      final isToday = lastDate.year == today.year &&
          lastDate.month == today.month &&
          lastDate.day == today.day;
      // If today exists in the range but the goal hasn't been met yet,
      // skip it so it doesn't look like the streak is already broken.
      if (isToday && heatmap[i].total < goal) i--;
    }
    while (i >= 0 && heatmap[i].total >= goal) {
      current++;
      i--;
    }

    // Best streak + days active over the whole window.
    int run = 0;
    for (final d in heatmap) {
      if (d.total > 0) daysActive++;
      if (d.total >= goal) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }

    // Weekly data (52 weeks from heatmap)
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = List.generate(52, (weekIdx) {
      final weekStart =
          currentMonday.subtract(Duration(days: (51 - weekIdx) * 7));
      final sel = <int>[];
      final zik = <int>[];
      for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        final dayDate = weekStart.add(Duration(days: dayOfWeek));
        final diff = dayDate.difference(start).inDays;
        if (diff >= 0 && diff < heatmap.length) {
          sel.add(heatmap[diff].selawat);
          zik.add(heatmap[diff].zikir);
        } else {
          sel.add(0);
          zik.add(0);
        }
      }
      return WeekData(selawat: sel, zikir: zik, weekStart: weekStart);
    });

    setState(() {
      _heatmapData = heatmap;
      _allTimeBreakdown =
          (sel: totalSel, zik: totalZik, top: topList.take(7).toList());
      _weeklyData = weeklyData;
      _currentStreak = current;
      _bestStreak = best;
      _daysActive = daysActive;
      _todayTotal = heatmap.isNotEmpty ? heatmap.last.total : 0;
      _todayCounts = heatmap.isEmpty
          ? const {}
          : {
              for (final (id, _, count) in heatmap.last.topDhikr) id: count,
            };
      _hasData = heatmap.any((d) => d.total > 0);
      _loading = false;
    });

    // Seed the cache so the next tab switch renders instantly.
    StatsCache.store(
      heatmap: heatmap,
      weeklyData: weeklyData,
      breakdown: const [],
      totalToday: heatmap.isNotEmpty ? heatmap.last.total : 0,
    );
  }

  void _onHeatmapDaySelected(int? idx) {
    setState(() {
      _selectedHeatmapIdx = _selectedHeatmapIdx == idx ? null : idx;
    });
  }

  /// Open the "Today's log" sheet from the stats page so users who notice
  /// a wrong number while reviewing can correct it without leaving stats.
  Future<void> _openTodayLog() async {
    final customs = SupabaseService.isAuthenticated
        ? await CustomDhikrService.list()
        : const <Dhikr>[];
    if (!mounted) return;
    HapticFeedback.lightImpact();
    await TodayLogSheet.show(
      context,
      counts: _todayCounts,
      customs: customs,
      onEdit: _setExactCount,
    );
  }

  /// Overwrite today's count for [dhikr] to exactly [newCount]. After a
  /// successful edit, refresh stats so the heatmap, totals, and breakdown
  /// reflect the corrected number.
  Future<bool> _setExactCount(Dhikr dhikr, int newCount) async {
    if (newCount < 0) return false;
    final prev = _todayCounts[dhikr.id] ?? 0;

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    SettingsService.saveLocalCount(
      dhikr.id,
      dhikr.category.name,
      newCount,
      today,
    );

    if (SupabaseService.isAuthenticated) {
      try {
        await CounterService.upsertCount(
          dhikrId: dhikr.id,
          category: dhikr.category.name,
          count: newCount,
        );
      } catch (_) {
        if (mounted) {
          showAppSnackBar(
            context,
            'Failed to update. Please try again.',
            backgroundColor: C.error,
          );
        }
        return false;
      }
    }

    if (mounted) {
      showAppSnackBar(
        context,
        'Updated · ${dhikr.name} · $prev → $newCount',
      );
      // Reload to recompute today's total, streak, and breakdown.
      StatsCache.invalidate();
      _loadStats();
    }
    return true;
  }

  void _showEditGoal() {
    final ctrl = TextEditingController(text: _dailyGoal.toString());
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    showAppFormSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          S.page, S.s8, S.page,
          MediaQuery.of(ctx).viewInsets.bottom + S.page,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Goal',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: S.s8),
            Text(
              'Set your daily recitation target.',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
            const SizedBox(height: S.s24),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
              decoration: InputDecoration(
                hintText: 'e.g. 100',
                suffixText: 'counts',
                suffixStyle: TextStyle(color: dark ? C.onDark3 : C.onLight3),
              ),
            ),
            const SizedBox(height: S.s24),
            SizedBox(
              width: double.infinity,
              child: BounceTap(
                onTap: () {
                  final val = int.tryParse(ctrl.text.trim());
                  if (val == null || val <= 0) {
                    showAppSnackBar(ctx, 'Enter a number greater than 0',
                        backgroundColor: C.error);
                    return;
                  }
                  SettingsService.dailyGoal = val;
                  setState(() => _dailyGoal = val);
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Daily goal set to $val');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: dark ? C.primarySoft : C.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: C.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    // Resolve data for breakdown sections
    final day = _selectedHeatmapIdx != null
        ? _heatmapData[_selectedHeatmapIdx!]
        : null;
    final selawatCount = day?.selawat ?? _allTimeBreakdown.sel;
    final zikirCount = day?.zikir ?? _allTimeBreakdown.zik;
    final topDhikr = day?.topDhikr ?? _allTimeBreakdown.top;

    // Date label for selected day
    final now = DateTime.now();
    final heatmapStart = now.subtract(const Duration(days: 363));
    String? selectedDateLabel;
    if (_selectedHeatmapIdx != null) {
      final d = heatmapStart.add(Duration(days: _selectedHeatmapIdx!));
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      selectedDateLabel = '${d.day} ${months[d.month - 1]} ${d.year}';
    }

    return Stack(
      children: [
        if (_hasData || _loading)
        Skeletonizer(
          enabled: _loading,
          child: AppRefreshIndicator(
            topOffset: MediaQuery.of(context).padding.top + 60,
            onRefresh: () async {
              await _loadStats();
            },
            child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 100),

          // ── Streak + Daily Progress hero card ──
          FadeIn(
            delay: const Duration(milliseconds: 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: StreakCard(
                dark: dark,
                tt: tt,
                streakDays: _loading ? 7 : _currentStreak,
                todayTotal: _loading ? 120 : _todayTotal,
                dailyGoal: _dailyGoal,
                onGoalTap: _showEditGoal,
              ),
            ),
          ),

          if (!_loading && _todayCounts.isNotEmpty) ...[
            const SizedBox(height: S.s8),
            FadeIn(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: BounceTap(
                  onTap: _openTodayLog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.s12,
                      vertical: S.s12,
                    ),
                    decoration: BoxDecoration(
                      color: dark ? C.dark2 : C.light2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dark ? C.dark3 : C.light3,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.pencil,
                          size: 14,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                        const SizedBox(width: S.s8),
                        Expanded(
                          child: Text(
                            "Edit today's log",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: dark ? C.onDark1 : C.onLight1,
                            ),
                          ),
                        ),
                        Text(
                          'Made a mistake?',
                          style: TextStyle(
                            fontSize: 11,
                            color: dark ? C.onDark3 : C.onLight3,
                          ),
                        ),
                        const SizedBox(width: S.s4),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 12,
                          color: dark ? C.onDark3 : C.onLight3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: S.s16),

          // ── Summary cards ──
          FadeIn(
            delay: const Duration(milliseconds: 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      icon: CupertinoIcons.star_fill,
                      iconColor: C.primarySoft,
                      label: 'Best Streak',
                      value: _loading ? '14 days' : '$_bestStreak days',
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: S.s12),
                  Expanded(
                    child: SummaryCard(
                      icon: CupertinoIcons.calendar,
                      iconColor: C.goldSoft,
                      label: 'Days Active',
                      value: _loading ? '30' : '$_daysActive',
                      dark: dark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: S.s12),

          FadeIn(
            delay: const Duration(milliseconds: 110),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      icon: CupertinoIcons.heart_fill,
                      iconColor: C.gold,
                      label: 'Total Selawat',
                      value: _loading ? '1,234' : fmtNum(_allTimeBreakdown.sel),
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: S.s12),
                  Expanded(
                    child: SummaryCard(
                      icon: CupertinoIcons.circle_grid_3x3_fill,
                      iconColor: C.primarySoft,
                      label: 'Total Zikir',
                      value: _loading ? '567' : fmtNum(_allTimeBreakdown.zik),
                      dark: dark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Weekly bar chart (selawat vs zikir) ──
          FadeIn(
            delay: const Duration(milliseconds: 160),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: WeeklyChart(
                dark: dark,
                tt: tt,
                weeklyData: _weeklyData,
                dailyGoal: _dailyGoal,
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Heatmap ──
          FadeIn(
            delay: const Duration(milliseconds: 220),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: StatsHeatmap(
                dark: dark,
                tt: tt,
                selectedIdx: _selectedHeatmapIdx,
                onDaySelected: _onHeatmapDaySelected,
                heatmapData: _heatmapData,
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Category breakdown ──
          FadeIn(
            delay: const Duration(milliseconds: 280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: CategoryBreakdown(
                dark: dark,
                tt: tt,
                selawatCount: _loading ? 100 : selawatCount,
                zikirCount: _loading ? 50 : zikirCount,
                dateLabel: selectedDateLabel,
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Top dhikr list ──
          FadeIn(
            delay: const Duration(milliseconds: 340),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: TopDhikrList(
                dark: dark,
                tt: tt,
                items: _loading
                    ? [('Selawat Nabi', 'Selawat', 100), ('Subhanallah', 'Zikir', 50)]
                    : topDhikr,
                dateLabel: selectedDateLabel,
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
        ],
      ),
      ),
      )
        else
          SafeArea(
            child: AppRefreshIndicator(
              onRefresh: () async {
                await _loadStats();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: S.page),
                      child: _EmptyStatsView(
                        onGoToTasbih: widget.onGoToTasbih ?? () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FrostedBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page, vertical: S.s16),
              child: FadeIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistics', style: tt.headlineLarge),
                    const SizedBox(height: S.s4),
                    Text('Your selawat & zikir journey', style: tt.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ──
class _EmptyStatsView extends StatelessWidget {
  const _EmptyStatsView({required this.onGoToTasbih});
  final VoidCallback onGoToTasbih;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        const Spacer(flex: 2),
        FadeIn(
          child: Text('📊', style: TextStyle(fontSize: 56)),
        ),
        const SizedBox(height: S.s24),
        FadeIn(
          delay: const Duration(milliseconds: 80),
          child: Text(
            'No Activity Yet',
            style: tt.headlineLarge,
          ),
        ),
        const SizedBox(height: S.s8),
        FadeIn(
          delay: const Duration(milliseconds: 120),
          child: Text(
            'Start counting selawat and zikir\nto see your statistics here',
            style: tt.bodyMedium?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: S.s40),
        FadeIn(
          delay: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            child: BounceTap(
              onTap: onGoToTasbih,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: S.s16),
                decoration: BoxDecoration(
                  color: dark ? C.primarySoft : C.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Go to Tasbih',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: C.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}
