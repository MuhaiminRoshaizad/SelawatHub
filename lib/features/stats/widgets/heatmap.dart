import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/stats/models/day_data.dart';
import 'package:selawathub/features/stats/stats_utils.dart';

class StatsHeatmap extends StatefulWidget {
  const StatsHeatmap({
    super.key,
    required this.dark,
    required this.tt,
    required this.selectedIdx,
    required this.onDaySelected,
    required this.heatmapData,
  });
  final bool dark;
  final TextTheme tt;
  final int? selectedIdx;
  final ValueChanged<int?> onDaySelected;
  final List<DayData> heatmapData;

  @override
  State<StatsHeatmap> createState() => _StatsHeatmapState();
}

class _StatsHeatmapState extends State<StatsHeatmap> {
  static const _weeks = 52;
  static const _daysPerWeek = 7;
  static const _cellSize = 20.0;
  static const _cellGap = 4.0;
  static const _columnWidth = _cellSize + _cellGap;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final tt = widget.tt;
    final selectedIdx = widget.selectedIdx;

    final now = DateTime.now();
    final startDate = now.subtract(
      const Duration(days: _weeks * _daysPerWeek - 1),
    );
    final monthLabels = <(int weekIdx, String label)>[];
    int lastMonth = -1;
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    for (int w = 0; w < _weeks; w++) {
      final d = startDate.add(Duration(days: w * _daysPerWeek));
      if (d.month != lastMonth) {
        monthLabels.add((w, monthNames[d.month - 1]));
        lastMonth = d.month;
      }
    }

    String? selectedLabel;
    int? selectedTotal;
    if (selectedIdx != null) {
      final d = startDate.add(Duration(days: selectedIdx));
      selectedLabel = '${d.day} ${monthNames[d.month - 1]}';
      selectedTotal = widget.heatmapData[selectedIdx].total;
    }

    final gridWidth = _weeks * _columnWidth;

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
                          fmtNum(selectedTotal!),
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

          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: gridWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month labels
                  SizedBox(
                    height: 14,
                    width: gridWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final (wIdx, label) in monthLabels)
                          Positioned(
                            left: wIdx * _columnWidth,
                            top: 0,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                color: dark ? C.onDark3 : C.onLight3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: S.s8),

                  // Grid
                  SizedBox(
                    height: (_daysPerWeek * _cellSize) +
                        ((_daysPerWeek - 1) * _cellGap),
                    child: Row(
                      children: List.generate(_weeks, (week) {
                        return SizedBox(
                          width: _columnWidth,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _cellGap / 2,
                            ),
                            child: Column(
                              children: List.generate(_daysPerWeek, (day) {
                                final idx = week * _daysPerWeek + day;
                                final data = idx < widget.heatmapData.length
                                    ? widget.heatmapData[idx]
                                    : null;
                                final level = data?.level ?? 0;
                                final isSelected = selectedIdx == idx;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(_cellGap / 2),
                                    child: GestureDetector(
                                      onTap: () => widget.onDaySelected(idx),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        decoration: BoxDecoration(
                                          color: _levelColor(level, dark),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: isSelected
                                              ? Border.all(
                                                  color: dark
                                                      ? C.onDark1
                                                      : C.onLight1,
                                                  width: 1.5,
                                                )
                                              : null,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: (dark
                                                            ? C.primarySoft
                                                            : C.primary)
                                                        .withValues(
                                                            alpha: 0.4),
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
                ],
              ),
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
