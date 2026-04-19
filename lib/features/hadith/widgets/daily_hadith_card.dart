import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/hadith/models/doa.dart';

// ─────────────────────────────────────────────────────────
//  Daily Hadith Card
// ─────────────────────────────────────────────────────────

class DailyHadithCard extends StatelessWidget {
  const DailyHadithCard({
    super.key,
    required this.hadith,
    required this.dark,
    required this.tt,
  });

  final NawawiHadith hadith;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark
            ? C.primaryMuted.withValues(alpha: 0.14)
            : C.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? C.primarySoft.withValues(alpha: 0.12)
              : C.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: C.primaryGlow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'HADITH OF THE DAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: dark ? C.primarySoft : C.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: dark ? C.dark4 : C.lightDivider,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hadith.topic,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s16),

          // Arabic text
          if (hadith.arabic.isNotEmpty) ...[
            Text(
              hadith.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.9,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
            const SizedBox(height: S.s12),
          ],

          // Translation
          Text(
            '\u201C',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: dark
                  ? C.primarySoft.withValues(alpha: 0.3)
                  : C.primary.withValues(alpha: 0.15),
              height: 0.6,
            ),
          ),
          const SizedBox(height: S.s4),
          Text(
            hadith.translation,
            style: tt.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontSize: 15,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
          const SizedBox(height: S.s12),

          // Narrator + source
          Text(
            '— ${hadith.narrator}${hadith.source.isNotEmpty ? ' (${hadith.source})' : ''}',
            style: tt.bodySmall?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
