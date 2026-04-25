import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/stats/stats_utils.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class TopDhikrList extends StatelessWidget {
  const TopDhikrList({
    super.key,
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
    final l = AppL10n.of(context);
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
                      Text(l.statsTopMostRecited, style: tt.titleMedium),
                      const SizedBox(height: S.s4),
                      Text(
                        dateLabel != null
                            ? l.statsTopOnDate(dateLabel!)
                            : l.statsTopSubtitle,
                        style: tt.bodySmall?.copyWith(
                          color: dark ? C.onDark3 : C.onLight3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: S.s16),
            if (items.isEmpty)
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
            else
              ...List.generate(items.length.clamp(0, 7), (i) {
                final (name, category, count) = items[i];
                final isSelawat = category == 'Selawat';
                final tagColor = isSelawat ? C.gold : (dark ? C.primarySoft : C.primary);
                final tagBg = isSelawat
                    ? C.gold.withValues(alpha: 0.15)
                    : (dark ? C.primarySoft : C.primary).withValues(alpha: 0.15);
                return Container(
                  margin: EdgeInsets.only(
                    bottom: i < items.length.clamp(0, 7) - 1 ? S.s8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: S.s12,
                    vertical: S.s12,
                  ),
                  decoration: BoxDecoration(
                    color: dark
                        ? C.dark2.withValues(alpha: 0.5)
                        : C.light1.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
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
                            color: dark ? C.onDark3 : C.onLight3,
                          ),
                        ),
                      ),
                      const SizedBox(width: S.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _prettifyName(name),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: dark ? C.onDark1 : C.onLight1,
                              ),
                            ),
                            const SizedBox(height: S.s4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: S.s6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tagBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category.toLowerCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tagColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        fmtNum(count),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: dark ? C.onDark1 : C.onLight1,
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

  /// Converts "selawat-jibril" → "Selawat Jibril"
  String _prettifyName(String raw) {
    final s = raw.startsWith('custom:') ? raw.substring(7) : raw;
    return s
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
