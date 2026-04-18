import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

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
                  Text('Your selawat journey', style: tt.bodyMedium),
                ],
              ),
            ),
          ),

          const SizedBox(height: S.s24),

          // ── Summary cards ──
          FadeIn(
            delay: const Duration(milliseconds: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: CupertinoIcons.flame_fill,
                      iconColor: C.gold,
                      label: 'Current Streak',
                      value: '19 days',
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: S.s12),
                  Expanded(
                    child: _SummaryCard(
                      icon: CupertinoIcons.star_fill,
                      iconColor: C.primarySoft,
                      label: 'Best Streak',
                      value: '34 days',
                      dark: dark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: S.s12),

          FadeIn(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: CupertinoIcons.sum,
                      iconColor: C.primarySoft,
                      label: 'Total Selawat',
                      value: '28,450',
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

          const SizedBox(height: S.s32),

          // ── Weekly bar chart ──
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
              child: _Heatmap(dark: dark, tt: tt),
            ),
          ),

          const SizedBox(height: S.s32),

          // ── Dhikr breakdown ──
          FadeIn(
            delay: const Duration(milliseconds: 280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: _DhikrBreakdown(dark: dark, tt: tt),
            ),
          ),

          const SizedBox(height: S.s80),
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

// ── Weekly bar chart ──
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.dark, required this.tt});
  final bool dark;
  final TextTheme tt;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _values = [820, 1200, 650, 1500, 2000, 1100, 1400];
  static const _maxVal = 2000;

  @override
  Widget build(BuildContext context) {
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
                '8,670 total',
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.primarySoft : C.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = _values[i] / _maxVal;
                final isToday = i == DateTime.now().weekday - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        if (isToday)
                          Padding(
                            padding: const EdgeInsets.only(bottom: S.s4),
                            child: Text(
                              '${_values[i]}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: dark ? C.primarySoft : C.primary,
                              ),
                            ),
                          ),
                        // Bar
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio.clamp(0.05, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? (dark ? C.primarySoft : C.primary)
                                    : (dark
                                        ? C.primarySoft.withValues(alpha: 0.25)
                                        : C.primary.withValues(alpha: 0.15)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: S.s8),
                        // Day label
                        Text(
                          _days[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? (dark ? C.onDark1 : C.onLight1)
                                : (dark ? C.onDark3 : C.onLight3),
                          ),
                        ),
                      ],
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

// ── Contribution heatmap ──
class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.dark, required this.tt});
  final bool dark;
  final TextTheme tt;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr'];
  static const _weeks = 16;
  static const _daysPerWeek = 7;

  @override
  Widget build(BuildContext context) {
    // Generate mock activity data (seeded for consistency)
    final rng = Random(42);
    final data = List.generate(
      _weeks * _daysPerWeek,
      (i) {
        final r = rng.nextDouble();
        if (r < 0.15) return 0;
        if (r < 0.35) return 1;
        if (r < 0.6) return 2;
        if (r < 0.85) return 3;
        return 4;
      },
    );

    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity', style: tt.titleMedium),
          const SizedBox(height: S.s4),
          Text('Last 4 months', style: tt.bodySmall),
          const SizedBox(height: S.s20),

          // Month labels
          Row(
            children: List.generate(_months.length, (i) {
              return Expanded(
                child: Text(
                  _months[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: dark ? C.onDark3 : C.onLight3,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: S.s8),

          // Heatmap grid
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
                        final level = idx < data.length ? data[idx] : 0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _levelColor(level, dark),
                                borderRadius: BorderRadius.circular(3),
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

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: TextStyle(fontSize: 10, color: dark ? C.onDark3 : C.onLight3)),
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
              Text('More', style: TextStyle(fontSize: 10, color: dark ? C.onDark3 : C.onLight3)),
            ],
          ),
        ],
      ),
    );
  }

  static Color _levelColor(int level, bool dark) {
    return switch (level) {
      0 => dark ? C.white.withValues(alpha: 0.04) : C.black.withValues(alpha: 0.04),
      1 => dark ? C.primarySoft.withValues(alpha: 0.2) : C.primary.withValues(alpha: 0.12),
      2 => dark ? C.primarySoft.withValues(alpha: 0.4) : C.primary.withValues(alpha: 0.25),
      3 => dark ? C.primarySoft.withValues(alpha: 0.65) : C.primary.withValues(alpha: 0.45),
      _ => dark ? C.primarySoft : C.primary,
    };
  }
}

// ── Dhikr breakdown ──
class _DhikrBreakdown extends StatelessWidget {
  const _DhikrBreakdown({required this.dark, required this.tt});
  final bool dark;
  final TextTheme tt;

  static const _items = [
    ('Subhanallah', 12400, 0.44),
    ('Alhamdulillah', 9850, 0.35),
    ('Allahu Akbar', 6200, 0.21),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dhikr Breakdown', style: tt.titleMedium),
          const SizedBox(height: S.s20),
          ...List.generate(_items.length, (i) {
            final (name, count, ratio) = _items[i];
            final colors = [C.primarySoft, C.gold, C.primaryMuted];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _items.length - 1 ? S.s16 : 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors[i],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: S.s8),
                      Expanded(child: Text(name, style: tt.titleSmall)),
                      Text(
                        _fmtNum(count),
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                      ),
                      const SizedBox(width: S.s8),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: dark ? C.onDark3 : C.onLight3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: S.s8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: dark
                          ? C.white.withValues(alpha: 0.04)
                          : C.black.withValues(alpha: 0.04),
                      valueColor: AlwaysStoppedAnimation(colors[i]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _fmtNum(int n) {
    if (n < 1000) return '$n';
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
