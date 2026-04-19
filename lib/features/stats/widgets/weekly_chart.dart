import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/stats/stats_utils.dart';

/// Weekly chart data model.
class WeekData {
  final List<int> selawat;
  final List<int> zikir;
  final DateTime weekStart;

  const WeekData({
    required this.selawat,
    required this.zikir,
    required this.weekStart,
  });

  int get total =>
      List.generate(7, (i) => selawat[i] + zikir[i]).reduce((a, b) => a + b);
}

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({
    super.key,
    required this.dark,
    required this.tt,
    required this.weeklyData,
  });
  final bool dark;
  final TextTheme tt;
  final List<WeekData> weeklyData;

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _maxVal = 2000;
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late final PageController _pageController;
  late int _currentPage;
  int? _selectedIdx;

  @override
  void initState() {
    super.initState();
    final totalPages = widget.weeklyData.length;
    _currentPage = totalPages > 0 ? totalPages - 1 : 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _weekLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${_months[weekStart.month - 1]} ${weekStart.day} – '
        '${_months[weekEnd.month - 1]} ${weekEnd.day}';
  }

  void _goToPage(int page) {
    if (page < 0 || page >= widget.weeklyData.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final tt = widget.tt;
    final totalWeeks = widget.weeklyData.length;

    if (totalWeeks == 0) {
      return Container(
        padding: const EdgeInsets.all(S.s20),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No weekly data yet',
            style: tt.bodyMedium?.copyWith(
              color: dark ? C.onDark3 : C.onLight3,
            ),
          ),
        ),
      );
    }

    final week = widget.weeklyData[_currentPage];

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
              GestureDetector(
                onTap: _currentPage > 0
                    ? () => _goToPage(_currentPage - 1)
                    : null,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 16,
                  color: _currentPage > 0
                      ? (dark ? C.onDark2 : C.onLight2)
                      : (dark ? C.onDark3 : C.onLight3).withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: S.s8),
              Expanded(
                child: Text(
                  _weekLabel(week.weekStart),
                  style: tt.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: S.s8),
              GestureDetector(
                onTap: _currentPage < totalWeeks - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: _currentPage < totalWeeks - 1
                      ? (dark ? C.onDark2 : C.onLight2)
                      : (dark ? C.onDark3 : C.onLight3).withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s4),
          Center(
            child: Text(
              '${fmtNum(week.total)} total',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.primarySoft : C.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
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

          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalWeeks,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                  _selectedIdx = null;
                });
              },
              itemBuilder:(context, pageIdx) {
                final w = widget.weeklyData[pageIdx];
                final isCurrentWeekPage = pageIdx == totalWeeks - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final sRatio = w.selawat[i] / _maxVal;
                    final zRatio = w.zikir[i] / _maxVal;
                    final isToday = isCurrentWeekPage &&
                        i == DateTime.now().weekday - 1;
                    final isSelected =
                        pageIdx == _currentPage && _selectedIdx == i;
                    final isActive = isSelected ||
                        (pageIdx == _currentPage &&
                            _selectedIdx == null &&
                            isToday);
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
                                    '${w.selawat[i] + w.zikir[i]}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: dark ? C.primarySoft : C.primary,
                                    ),
                                  ),
                                ),
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor:
                                      (sRatio + zRatio).clamp(0.05, 1.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: (w.zikir[i]).clamp(1, 9999),
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
                                        flex: (w.selawat[i]).clamp(1, 9999),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? (dark
                                                    ? C.primarySoft
                                                    : C.primary)
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
                );
              },
            ),
          ),

          // Tooltip for selected bar (below chart)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _selectedIdx != null
                ? _BarTooltip(
                    day: _days[_selectedIdx!],
                    selawat: widget.weeklyData[_currentPage].selawat[_selectedIdx!],
                    zikir: widget.weeklyData[_currentPage].zikir[_selectedIdx!],
                    dark: dark,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

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
      margin: const EdgeInsets.only(top: S.s16),
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
          const SizedBox(width: S.s8),
          Text(
            fmtNum(selawat + zikir),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: dark ? C.onDark3 : C.onLight3,
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
            fmtNum(selawat),
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
            fmtNum(zikir),
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
