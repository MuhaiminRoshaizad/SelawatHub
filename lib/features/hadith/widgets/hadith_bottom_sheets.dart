import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────
//  Source info bottom sheet
// ─────────────────────────────────────────────────────────

void showSourceInfoSheet({
  required BuildContext context,
  required String title,
  required String sourceName,
  required String description,
  required String endpoint,
  required Color accentColor,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final tt = Theme.of(context).textTheme;

  showAppBottomSheet(
    context: context,
    initialSize: 0.45,
    minSize: 0.3,
    maxSize: 0.7,
    headerChildren: [
      Expanded(
        child: Text(
          title,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: accentColor,
          ),
        ),
      ),
    ],
    bodyChildren: [
      // Source name
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(S.s16),
        decoration: BoxDecoration(
          color: dark
              ? accentColor.withValues(alpha: 0.08)
              : accentColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark
                ? accentColor.withValues(alpha: 0.12)
                : accentColor.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark3 : C.onLight3,
              ),
            ),
            const SizedBox(height: S.s4),
            Text(
              sourceName,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: S.s12),

      // Description
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(S.s16),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light3,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark3 : C.onLight3,
              ),
            ),
            const SizedBox(height: S.s4),
            Text(
              description,
              style: tt.bodyMedium?.copyWith(
                height: 1.5,
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: S.s12),

      // Endpoint — tappable link
      GestureDetector(
        onTap: () => launchUrl(
          Uri.parse('https://dua-data-api.vercel.app/api$endpoint'),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(S.s16),
          decoration: BoxDecoration(
            color: dark
                ? accentColor.withValues(alpha: 0.06)
                : accentColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark
                  ? accentColor.withValues(alpha: 0.12)
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.link,
                size: 14,
                color: accentColor,
              ),
              const SizedBox(width: S.s8),
              Expanded(
                child: Text(
                  'https://dua-data-api.vercel.app/api$endpoint',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                    decoration: TextDecoration.underline,
                    decorationColor: accentColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: S.s8),
              Icon(
                CupertinoIcons.arrow_up_right_square,
                size: 14,
                color: accentColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────
//  Zikr / Adkar Detail Bottom Sheet
// ─────────────────────────────────────────────────────────

void showZikrDetailSheet({
  required BuildContext context,
  required String title,
  required String arabic,
  required String translation,
  required String transliteration,
  required String times,
  required String benefit,
  required Color accentColor,
  required Color accentSoft,
  required Color accentGlow,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final tt = Theme.of(context).textTheme;

  showAppBottomSheet(
    context: context,
    initialSize: 0.7,
    minSize: 0.4,
    maxSize: 0.92,
    headerChildren: [
      // Times badge
      if (times.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentGlow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.repeat,
                size: 12,
                color: dark ? accentSoft : accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${times}x',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: dark ? accentSoft : accentColor,
                ),
              ),
            ],
          ),
        ),
    ],
    bodyChildren: [
      // Title
      Text(
        title,
        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),

      const SizedBox(height: S.s20),

      // Arabic text
      if (arabic.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(S.s24),
          decoration: BoxDecoration(
            color: dark
                ? accentColor.withValues(alpha: 0.08)
                : accentColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: dark
                  ? accentSoft.withValues(alpha: 0.1)
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 2.0,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
        ),

      // Transliteration
      if (transliteration.isNotEmpty) ...[
        const SizedBox(height: S.s20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(S.s16),
          decoration: BoxDecoration(
            color: dark ? C.dark3 : C.light3,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transliteration',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(height: S.s8),
              Text(
                transliteration,
                style: tt.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: dark ? C.onDark2 : C.onLight2,
                ),
              ),
            ],
          ),
        ),
      ],

      // Translation
      if (translation.isNotEmpty) ...[
        const SizedBox(height: S.s16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(S.s16),
          decoration: BoxDecoration(
            color: dark
                ? accentColor.withValues(alpha: 0.06)
                : accentColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark
                  ? accentSoft.withValues(alpha: 0.08)
                  : accentColor.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Translation',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: dark ? accentSoft : accentColor,
                ),
              ),
              const SizedBox(height: S.s8),
              Text(
                translation,
                style: tt.bodyMedium?.copyWith(
                  height: 1.6,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
            ],
          ),
        ),
      ],

      // Benefits
      if (benefit.isNotEmpty) ...[
        const SizedBox(height: S.s16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(S.s16),
          decoration: BoxDecoration(
            color: dark ? C.dark3 : C.light3,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 14,
                    color: dark ? accentSoft : accentColor,
                  ),
                  const SizedBox(width: S.s6),
                  Text(
                    'Benefits',
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: dark ? accentSoft : accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: S.s8),
              Text(
                benefit,
                style: tt.bodyMedium?.copyWith(
                  height: 1.6,
                  color: dark ? C.onDark2 : C.onLight2,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
