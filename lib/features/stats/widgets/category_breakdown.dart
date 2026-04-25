import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/stats/stats_utils.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
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
    final l = AppL10n.of(context);
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
                Text(l.statsCategoryBreakdown, style: tt.titleMedium),
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
                    l.statsNoActivityOnDay,
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
          fmtNum(count),
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
