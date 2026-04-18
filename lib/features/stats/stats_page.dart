import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/animations/fire_emoji.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

// ── Mock per-day data model ──
class _DayData {
  final int selawat;
  final int zikir;
  final List<(String name, String category, int count)> topDhikr;

  const _DayData({
    required this.selawat,
    required this.zikir,
    required this.topDhikr,
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

// Pre-generated mock data for heatmap (16 weeks × 7 days = 112 days)
final List<_DayData> _heatmapData = _generateHeatmapData();

List<_DayData> _generateHeatmapData() {
  final rng = Random(42);
  const dhikrNames = [
    ('Selawat Jibril', 'Selawat'),
    ('Selawat Ibrahimiyah', 'Selawat'),
    ('Selawat Nariah', 'Selawat'),
    ('Selawat Al-Fatih', 'Selawat'),
    ('Selawat Tafrijiyah', 'Selawat'),
    ('Subhanallah', 'Zikir'),
    ('Alhamdulillah', 'Zikir'),
    ('Allahu Akbar', 'Zikir'),
    ('Astaghfirullah', 'Zikir'),
    ('Tahlil', 'Zikir'),
  ];

  return List.generate(112, (i) {
    final r = rng.nextDouble();
    if (r < 0.15) {
      return const _DayData(selawat: 0, zikir: 0, topDhikr: []);
    }

    final sel = (rng.nextInt(800) + 100);
    final zik = (rng.nextInt(500) + 50);

    // Generate top dhikr for this day
    final shuffled = List.of(dhikrNames)..shuffle(rng);
    final top = shuffled.take(4 + rng.nextInt(3)).toList();
    var remaining = sel + zik;
    final topWithCounts = <(String, String, int)>[];
    for (int j = 0; j < top.length; j++) {
      final portion = j < top.length - 1
          ? (remaining * (0.15 + rng.nextDouble() * 0.3)).round()
          : remaining;
      if (portion <= 0) continue;
      remaining -= portion;
      topWithCounts.add((top[j].$1, top[j].$2, portion));
    }
    topWithCounts.sort((a, b) => b.$3.compareTo(a.$3));

    return _DayData(selawat: sel, zikir: zik, topDhikr: topWithCounts);
  });
}

// All-time aggregate data
final _allTimeBreakdown = (() {
  int totalSel = 0, totalZik = 0;
  final dhikrTotals = <String, (String, int)>{};
  for (final d in _heatmapData) {
    totalSel += d.selawat;
    totalZik += d.zikir;
    for (final (name, cat, count) in d.topDhikr) {
      final prev = dhikrTotals[name];
      dhikrTotals[name] = (cat, (prev?.$2 ?? 0) + count);
    }
  }
  final topList =
      dhikrTotals.entries.map((e) => (e.key, e.value.$1, e.value.$2)).toList()
        ..sort((a, b) => b.$3.compareTo(a.$3));
  return (sel: totalSel, zik: totalZik, top: topList.take(7).toList());
})();

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int? _selectedHeatmapIdx;

  void _onHeatmapDaySelected(int? idx) {
    setState(() {
      // Tap same cell → deselect
      _selectedHeatmapIdx = _selectedHeatmapIdx == idx ? null : idx;
    });
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
    final heatmapStart = now.subtract(const Duration(days: 111));
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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: S.s16),

          // Header
          FadeIn(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
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

          const SizedBox(height: S.s24),

          // ── Streak + Daily Progress hero card ──
          FadeIn(
            delay: const Duration(milliseconds: 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: _StreakCard(dark: dark, tt: tt),
            ),
          ),

          const SizedBox(height: S.s16),

          // ── Summary cards ──
          FadeIn(
            delay: const Duration(milliseconds: 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: CupertinoIcons.star_fill,
                      iconColor: C.primarySoft,
                      label: 'Best Streak',
                      value: '34 days',
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: S.s12),
                  Expanded(
                    child: _SummaryCard(
                      icon: CupertinoIcons.calendar,
                      iconColor: C.goldSoft,
                      label: 'Days Active',
                      value: '45',
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
                    child: _SummaryCard(
                      icon: CupertinoIcons.heart_fill,
                      iconColor: C.gold,
                      label: 'Total Selawat',
                      value: _fmtNum(_allTimeBreakdown.sel),
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: S.s12),
                  Expanded(
                    child: _SummaryCard(
                      icon: CupertinoIcons.circle_grid_3x3_fill,
                      iconColor: C.primarySoft,
                      label: 'Total Zikir',
                      value: _fmtNum(_allTimeBreakdown.zik),
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
              child: _WeeklyChart(dark: dark, tt: tt),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Heatmap ──
          FadeIn(
            delay: const Duration(milliseconds: 220),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: _Heatmap(
                dark: dark,
                tt: tt,
                selectedIdx: _selectedHeatmapIdx,
                onDaySelected: _onHeatmapDaySelected,
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Category breakdown ──
          FadeIn(
            delay: const Duration(milliseconds: 280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: _CategoryBreakdown(
                dark: dark,
                tt: tt,
                selawatCount: selawatCount,
                zikirCount: zikirCount,
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
              child: _TopDhikrList(
                dark: dark,
                tt: tt,
                items: topDhikr,
                dateLabel: selectedDateLabel,
              ),
            ),
          ),

          const SizedBox(height: S.s80),
        ],
      ),
    );
  }
}

// ── Streak hero card ──
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.dark, required this.tt});
  final bool dark;
  final TextTheme tt;

  // Mock streak days — change to test different tiers
  static const _streakDays = 1;

  @override
  Widget build(BuildContext context) {
    final tier = streakTierFromDays(_streakDays);
    final tierLabel = switch (tier) {
      StreakTier.dead => 'No Streak',
      StreakTier.burning => '$_streakDays Day Streak',
      StreakTier.blazing => '$_streakDays Day Streak 🔥',
      StreakTier.legendary => '$_streakDays Day Streak ⚡',
    };
    final subtitle = switch (tier) {
      StreakTier.dead => 'Start reciting today!',
      StreakTier.burning => 'Keep it going!',
      StreakTier.blazing => 'You\'re on fire!',
      StreakTier.legendary => 'Legendary status!',
    };

    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? [C.primaryMuted, C.dark3] : [C.primary, C.primarySoft],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              FireEmoji(size: 36, tier: tier),
              const SizedBox(width: S.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tierLabel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: C.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: C.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: S.s20),
          Row(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: C.white.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                '1,240 / 2,000',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: C.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.62,
              minHeight: 6,
              backgroundColor: C.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                C.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary card ──
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.dark,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(S.s16),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: S.s12),
          Text(value, style: tt.titleLarge),
          const SizedBox(height: S.s2),
          Text(label, style: tt.bodySmall),
        ],
      ),
    );
  }
}

// ── Weekly bar chart (selawat vs zikir stacked, interactive) ──
class _WeeklyChart extends StatefulWidget {
  const _WeeklyChart({required this.dark, required this.tt});
  final bool dark;
  final TextTheme tt;

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _selawat = [520, 800, 350, 900, 1200, 700, 850];
  static const _zikir = [300, 400, 300, 600, 800, 400, 550];
  static const _maxVal = 2000;

  int? _selectedIdx;

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final tt = widget.tt;
    final totalWeek = List.generate(
      7,
      (i) => _selawat[i] + _zikir[i],
    ).reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('This Week', style: tt.titleMedium),
              const Spacer(),
              Text(
                '${_fmtNum(totalWeek)} total',
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.primarySoft : C.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s8),
          Row(
            children: [
              _LegendDot(
                color: dark ? C.primarySoft : C.primary,
                label: 'Selawat',
              ),
              const SizedBox(width: S.s16),
              _LegendDot(color: C.gold, label: 'Zikir'),
            ],
          ),
          const SizedBox(height: S.s20),

          // Tooltip for selected bar
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _selectedIdx != null
                ? _BarTooltip(
                    day: _days[_selectedIdx!],
                    selawat: _selawat[_selectedIdx!],
                    zikir: _zikir[_selectedIdx!],
                    dark: dark,
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final sRatio = _selawat[i] / _maxVal;
                final zRatio = _zikir[i] / _maxVal;
                final isToday = i == DateTime.now().weekday - 1;
                final isSelected = _selectedIdx == i;
                final isActive =
                    isSelected || (_selectedIdx == null && isToday);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIdx = _selectedIdx == i ? null : i;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isActive)
                            Padding(
                              padding: const EdgeInsets.only(bottom: S.s4),
                              child: Text(
                                '${_selawat[i] + _zikir[i]}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: dark ? C.primarySoft : C.primary,
                                ),
                              ),
                            ),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: (sRatio + zRatio).clamp(0.05, 1.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: (_zikir[i]).clamp(1, 9999),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? C.gold
                                            : C.gold.withValues(
                                                alpha: dark ? 0.3 : 0.25,
                                              ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: (_selawat[i]).clamp(1, 9999),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? (dark ? C.primarySoft : C.primary)
                                            : (dark
                                                  ? C.primarySoft.withValues(
                                                      alpha: 0.3,
                                                    )
                                                  : C.primary.withValues(
                                                      alpha: 0.2,
                                                    )),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(4),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: S.s8),
                          Text(
                            _days[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isActive
                                  ? (dark ? C.onDark1 : C.onLight1)
                                  : (dark ? C.onDark3 : C.onLight3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Tooltip card shown above weekly chart bars
class _BarTooltip extends StatelessWidget {
  const _BarTooltip({
    required this.day,
    required this.selawat,
    required this.zikir,
    required this.dark,
  });
  final String day;
  final int selawat;
  final int zikir;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: S.s12),
      padding: const EdgeInsets.symmetric(horizontal: S.s16, vertical: S.s12),
      decoration: BoxDecoration(
        color: dark ? C.dark2 : C.light1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (dark ? C.primarySoft : C.primary).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dark ? C.primarySoft : C.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: S.s4),
          Text(
            _fmtNum(selawat),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
          const SizedBox(width: S.s16),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: C.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: S.s4),
          Text(
            _fmtNum(zikir),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: S.s4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: dark ? C.onDark3 : C.onLight3),
        ),
      ],
    );
  }
}

// ── Contribution heatmap (GitHub-style, interactive) ──
class _Heatmap extends StatelessWidget {
  const _Heatmap({
    required this.dark,
    required this.tt,
    required this.selectedIdx,
    required this.onDaySelected,
  });
  final bool dark;
  final TextTheme tt;
  final int? selectedIdx;
  final ValueChanged<int?> onDaySelected;

  static const _weeks = 16;
  static const _daysPerWeek = 7;

  @override
  Widget build(BuildContext context) {
    // Compute month labels from actual dates
    final now = DateTime.now();
    final startDate = now.subtract(
      const Duration(days: _weeks * _daysPerWeek - 1),
    );
    final monthLabels = <(int weekIdx, String label)>[];
    int lastMonth = -1;
    const monthNames = [
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
    for (int w = 0; w < _weeks; w++) {
      final d = startDate.add(Duration(days: w * _daysPerWeek));
      if (d.month != lastMonth) {
        monthLabels.add((w, monthNames[d.month - 1]));
        lastMonth = d.month;
      }
    }

    // Selected day info
    String? selectedLabel;
    int? selectedTotal;
    if (selectedIdx != null) {
      final d = startDate.add(Duration(days: selectedIdx!));
      selectedLabel = '${d.day} ${monthNames[d.month - 1]}';
      selectedTotal = _heatmapData[selectedIdx!].total;
    }

    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activity', style: tt.titleMedium),
                    const SizedBox(height: S.s4),
                    Text(
                      selectedIdx != null
                          ? 'Tap again to deselect'
                          : 'Tap a day to filter stats below',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
              // Selected day badge
              if (selectedIdx != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.s12,
                      vertical: S.s6,
                    ),
                    decoration: BoxDecoration(
                      color: (dark ? C.primarySoft : C.primary).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedLabel!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: dark ? C.primarySoft : C.primary,
                          ),
                        ),
                        const SizedBox(width: S.s6),
                        Text(
                          _fmtNum(selectedTotal!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dark ? C.onDark1 : C.onLight1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: S.s20),

          // Month labels
          Row(
            children: List.generate(_weeks, (w) {
              final match = monthLabels.where((m) => m.$1 == w);
              return Expanded(
                child: match.isNotEmpty
                    ? Text(
                        match.first.$2,
                        style: TextStyle(
                          fontSize: 10,
                          color: dark ? C.onDark3 : C.onLight3,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ),
          const SizedBox(height: S.s8),

          // Grid
          SizedBox(
            height: (_daysPerWeek * 14.0) + ((_daysPerWeek - 1) * 3.0),
            child: Row(
              children: List.generate(_weeks, (week) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      children: List.generate(_daysPerWeek, (day) {
                        final idx = week * _daysPerWeek + day;
                        final data = idx < _heatmapData.length
                            ? _heatmapData[idx]
                            : null;
                        final level = data?.level ?? 0;
                        final isSelected = selectedIdx == idx;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: GestureDetector(
                              onTap: () => onDaySelected(idx),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: _levelColor(level, dark),
                                  borderRadius: BorderRadius.circular(3),
                                  border: isSelected
                                      ? Border.all(
                                          color: dark ? C.onDark1 : C.onLight1,
                                          width: 1.5,
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                (dark
                                                        ? C.primarySoft
                                                        : C.primary)
                                                    .withValues(alpha: 0.4),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: S.s16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  fontSize: 10,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(width: S.s6),
              ...List.generate(5, (i) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: _levelColor(i, dark),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                );
              }),
              const SizedBox(width: S.s6),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 10,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _levelColor(int level, bool dark) {
    return switch (level) {
      0 =>
        dark
            ? C.white.withValues(alpha: 0.04)
            : C.black.withValues(alpha: 0.04),
      1 =>
        dark
            ? C.primarySoft.withValues(alpha: 0.2)
            : C.primary.withValues(alpha: 0.12),
      2 =>
        dark
            ? C.primarySoft.withValues(alpha: 0.4)
            : C.primary.withValues(alpha: 0.25),
      3 =>
        dark
            ? C.primarySoft.withValues(alpha: 0.65)
            : C.primary.withValues(alpha: 0.45),
      _ => dark ? C.primarySoft : C.primary,
    };
  }
}

// ── Category breakdown (Selawat vs Zikir) ──
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.dark,
    required this.tt,
    required this.selawatCount,
    required this.zikirCount,
    this.dateLabel,
  });
  final bool dark;
  final TextTheme tt;
  final int selawatCount;
  final int zikirCount;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final total = selawatCount + zikirCount;
    final selawatRatio = total > 0 ? selawatCount / total : 0.5;
    final zikirRatio = total > 0 ? zikirCount / total : 0.5;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(S.s20),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Category Breakdown', style: tt.titleMedium),
                if (dateLabel != null) ...[
                  const SizedBox(width: S.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.s8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: C.goldGlow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateLabel!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: C.gold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: S.s20),

            if (total == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: S.s16),
                  child: Text(
                    'No activity on this day',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (selawatRatio * 100).round().clamp(1, 99),
                        child: Container(
                          color: dark ? C.primarySoft : C.primary,
                        ),
                      ),
                      Expanded(
                        flex: (zikirRatio * 100).round().clamp(1, 99),
                        child: Container(color: C.gold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: S.s20),
              _CategoryRow(
                color: dark ? C.primarySoft : C.primary,
                label: 'Selawat',
                count: selawatCount,
                percentage: '${(selawatRatio * 100).round()}%',
                dark: dark,
                tt: tt,
              ),
              const SizedBox(height: S.s12),
              _CategoryRow(
                color: C.gold,
                label: 'Zikir',
                count: zikirCount,
                percentage: '${(zikirRatio * 100).round()}%',
                dark: dark,
                tt: tt,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.color,
    required this.label,
    required this.count,
    required this.percentage,
    required this.dark,
    required this.tt,
  });
  final Color color;
  final String label;
  final int count;
  final String percentage;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: S.s8),
        Expanded(child: Text(label, style: tt.titleSmall)),
        Text(
          _fmtNum(count),
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark2 : C.onLight2,
          ),
        ),
        const SizedBox(width: S.s8),
        SizedBox(
          width: 36,
          child: Text(
            percentage,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dark ? C.onDark3 : C.onLight3,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Top dhikr list ──
class _TopDhikrList extends StatelessWidget {
  const _TopDhikrList({
    required this.dark,
    required this.tt,
    required this.items,
    this.dateLabel,
  });
  final bool dark;
  final TextTheme tt;
  final List<(String name, String category, int count)> items;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(S.s20),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Most Recited', style: tt.titleMedium),
                      const SizedBox(height: S.s4),
                      Text(
                        dateLabel != null
                            ? 'On $dateLabel'
                            : 'Your top selawat & zikir',
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (dateLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.s8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: C.goldGlow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateLabel!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: C.gold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: S.s20),
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: S.s16),
                  child: Text(
                    'No activity on this day',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(items.length.clamp(0, 7), (i) {
                final (name, category, count) = items[i];
                final isSelawat = category == 'Selawat';
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < items.length.clamp(0, 7) - 1 ? S.s12 : 0,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: i < 3
                                ? C.gold
                                : (dark ? C.onDark3 : C.onLight3),
                          ),
                        ),
                      ),
                      const SizedBox(width: S.s8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: dark ? C.onDark1 : C.onLight1,
                              ),
                            ),
                            const SizedBox(height: S.s2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: S.s6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isSelawat ? C.goldGlow : C.primaryGlow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isSelawat
                                      ? C.gold
                                      : (dark ? C.primarySoft : C.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _fmtNum(count),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

String _fmtNum(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
