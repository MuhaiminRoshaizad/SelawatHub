import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/hadith/widgets/hadith_helpers.dart';

// ─────────────────────────────────────────────────────────
//  Category Card(grid item → taps to detail page)
// ─────────────────────────────────────────────────────────

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.count,
    required this.dark,
    required this.tt,
    required this.onTap,
  });

  final String category;
  final int count;
  final bool dark;
  final TextTheme tt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(S.s16),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? C.dark4 : C.lightDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: C.primaryGlow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                categoryIcon(category),
                size: 18,
                color: dark ? C.primarySoft : C.primary,
              ),
            ),
            const Spacer(),
            Text(
              capitalize(category),
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$count doa',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark3 : C.onLight3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
