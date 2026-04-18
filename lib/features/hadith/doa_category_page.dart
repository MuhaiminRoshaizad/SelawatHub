import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/hadith/models/doa.dart';

// ─────────────────────────────────────────────────────────
//  Doa Category Detail Page
// ─────────────────────────────────────────────────────────

class DoaCategoryPage extends StatelessWidget {
  const DoaCategoryPage({
    super.key,
    required this.category,
    required this.doas,
  });

  final String category;
  final List<Doa> doas;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: doas.length + 2, // spacer + items + bottom
            separatorBuilder: (_, i) {
              if (i == 0) return const SizedBox.shrink();
              return Divider(
                height: 1,
                color: dark ? C.dark4 : C.lightDivider,
                indent: S.page,
                endIndent: S.page,
              );
            },
            itemBuilder: (_, i) {
              // Top spacer for frosted bar
              if (i == 0) {
                return SizedBox(
                    height: MediaQuery.of(context).padding.top + 56);
              }
              // Bottom spacer
              if (i == doas.length + 1) {
                return SizedBox(
                    height: MediaQuery.of(context).padding.bottom +
                        56 +
                        S.s24);
              }
              final idx = i - 1;
              final doa = doas[idx];
              return FadeIn(
                delay: Duration(milliseconds: idx.clamp(0, 8) * 50),
                child: _DoaCard(
                  doa: doa,
                  index: idx + 1,
                  dark: dark,
                  tt: tt,
                ),
              );
            },
          ),

          // ── Frosted app bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedBar(
              child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: S.s16),
                          child: Icon(
                            CupertinoIcons.chevron_left,
                            size: 20,
                            color: dark ? C.onDark1 : C.onLight1,
                          ),
                        ),
                      ),
                      // Title
                      Expanded(
                        child: Text(
                          _capitalize(category),
                          style: tt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Info button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.info_circle,
                          size: 20,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                        onPressed: () =>
                            _showDoaSourceSheet(context, dark),
                      ),
                      // Count badge
                      Padding(
                        padding: const EdgeInsets.only(right: S.s16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: C.primaryGlow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${doas.length} doa',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dark ? C.primarySoft : C.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Individual Doa Card
// ─────────────────────────────────────────────────────────

class _DoaCard extends StatelessWidget {
  const _DoaCard({
    required this.doa,
    required this.index,
    required this.dark,
    required this.tt,
  });

  final Doa doa;
  final int index;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: S.page,
        vertical: S.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: C.primaryGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: dark ? C.primarySoft : C.primary,
                  ),
                ),
              ),
              const SizedBox(width: S.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doa.title.isNotEmpty)
                      Text(
                        doa.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dark ? C.onDark1 : C.onLight1,
                        ),
                      ),
                    if (doa.description.isNotEmpty) ...[
                      const SizedBox(height: S.s4),
                      Text(
                        doa.description,
                        style: tt.bodySmall?.copyWith(
                          color: dark ? C.onDark3 : C.onLight3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: S.s16),

          // ── Arabic text ──
          if (doa.arabic.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(S.s20),
              decoration: BoxDecoration(
                color: dark
                    ? C.primaryMuted.withValues(alpha: 0.08)
                    : C.primary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark
                      ? C.primarySoft.withValues(alpha: 0.08)
                      : C.primary.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
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
            ),

          // ── Transliteration ──
          if (doa.transliteration.isNotEmpty) ...[
            const SizedBox(height: S.s12),
            Text(
              doa.transliteration,
              style: tt.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

// ─────────────────────────────────────────────────────────
//  Doa source info bottom sheet
// ─────────────────────────────────────────────────────────

void _showDoaSourceSheet(BuildContext context, bool dark) {
  final tt = Theme.of(context).textTheme;

  showAppBottomSheet(
    context: context,
    initialSize: 0.4,
    minSize: 0.25,
    maxSize: 0.65,
    headerChildren: [
      Expanded(
        child: Text(
          'Source Info',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: dark ? C.primarySoft : C.primary,
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
          color: C.primaryGlow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark
                ? C.primarySoft.withValues(alpha: 0.12)
                : C.primary.withValues(alpha: 0.08),
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
              'Useful Duas Collection',
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
              '102 supplications from Quran & Sunnah, categorized by topic.',
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
          Uri.parse('https://dua-data-api.vercel.app/api/usefulDuas'),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(S.s16),
          decoration: BoxDecoration(
            color: dark
                ? C.primarySoft.withValues(alpha: 0.06)
                : C.primary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark
                  ? C.primarySoft.withValues(alpha: 0.12)
                  : C.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.link,
                size: 14,
                color: dark ? C.primarySoft : C.primary,
              ),
              const SizedBox(width: S.s8),
              Expanded(
                child: Text(
                  'https://dua-data-api.vercel.app/api/usefulDuas',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: dark ? C.primarySoft : C.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: (dark ? C.primarySoft : C.primary)
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: S.s8),
              Icon(
                CupertinoIcons.arrow_up_right_square,
                size: 14,
                color: (dark ? C.primarySoft : C.primary)
                    .withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
