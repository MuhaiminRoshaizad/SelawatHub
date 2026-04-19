import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

// ─────────────────────────────────────────────────────────
//  Shared Preview Card (compact, used for both adkar & post-salaah)
// ─────────────────────────────────────────────────────────

class ZikrPreviewCard extends StatelessWidget {
  const ZikrPreviewCard({
    super.key,
    required this.title,
    required this.arabic,
    required this.times,
    required this.dark,
    required this.tt,
    required this.accentColor,
    required this.accentSoft,
    required this.accentGlow,
    required this.onTap,
  });

  final String title;
  final String arabic;
  final String times;
  final bool dark;
  final TextTheme tt;
  final Color accentColor;
  final Color accentSoft;
  final Color accentGlow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(S.s16),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? C.dark4 : C.lightDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: S.s12),

            // Arabic preview
            if (arabic.isNotEmpty)
              Expanded(
                child: Text(
                  arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.8,
                    color: dark ? C.onDark1 : C.onLight1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: S.s12),

            // Bottom row: times badge + tap hint
            Row(
              children: [
                if (times.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentGlow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${times}x',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: dark ? accentSoft : accentColor,
                      ),
                    ),
                  ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 12,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
