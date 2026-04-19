import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/hadith/models/doa.dart';
import 'package:selawathub/features/hadith/widgets/hadith_helpers.dart';

// ─────────────────────────────────────────────────────────
//  Daily Doa Card
// ─────────────────────────────────────────────────────────

class DailyDoaCard extends StatelessWidget {
  const DailyDoaCard({
    super.key,
    required this.doa,
    required this.dark,
    required this.tt,
  });

  final Doa doa;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark
            ? C.gold.withValues(alpha: 0.08)
            : C.gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? C.goldSoft.withValues(alpha: 0.12)
              : C.gold.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: C.goldGlow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DOA OF THE DAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: dark ? C.goldSoft : C.gold,
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
                  capitalize(doa.category),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s12),

          // Title
          if (doa.title.isNotEmpty) ...[
            Text(
              doa.title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
            const SizedBox(height: S.s12),
          ],

          // Arabic
          if (doa.arabic.isNotEmpty) ...[
            Text(
              doa.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.9,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
            const SizedBox(height: S.s12),
          ],

          // Description (as usage context)
          if (doa.description.isNotEmpty)
            Text(
              doa.description,
              style: tt.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
        ],
      ),
    );
  }
}
