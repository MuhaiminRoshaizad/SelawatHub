import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/hadith/models/doa.dart';
import 'package:selawathub/features/hadith/models/doa_data.dart';

// ─────────────────────────────────────────────────────────
//  Hadith & Doa Page — Daily featured cards + doa browser
// ─────────────────────────────────────────────────────────

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});
  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  /// Which category index is currently expanded (-1 = none).
  int _expandedIdx = -1;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final today = dailyHadith();
    final todayDoa = dailyDoa();
    final grouped = doasByCategory();
    final categories = grouped.keys.toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: S.s16),

                  // ── Header ──
                  FadeIn(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hadith & Doa', style: tt.headlineLarge),
                              const SizedBox(height: S.s4),
                              Text(
                                'Your daily spiritual companion',
                                style: tt.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: dark ? C.dark3 : C.light3,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.share,
                            size: 16,
                            color: dark ? C.onDark2 : C.onLight2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: S.s24),

                  // ── Daily featured cards ──
                  FadeIn(
                    delay: const Duration(milliseconds: 80),
                    child: _DailyHadithCard(hadith: today, dark: dark, tt: tt),
                  ),
                  const SizedBox(height: S.s12),
                  FadeIn(
                    delay: const Duration(milliseconds: 160),
                    child: _DailyDoaCard(doa: todayDoa, dark: dark, tt: tt),
                  ),

                  const SizedBox(height: S.s32),

                  // ── Doa Collection header ──
                  FadeIn(
                    delay: const Duration(milliseconds: 240),
                    child: Text('Doa Collection', style: tt.titleLarge),
                  ),
                  const SizedBox(height: S.s4),
                  FadeIn(
                    delay: const Duration(milliseconds: 240),
                    child: Text(
                      'Browse supplications by category',
                      style: tt.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: S.s16),
                ],
              ),
            ),
          ),

          // ── Category accordion list ──
          SliverList.builder(
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final items = grouped[cat]!;
              final expanded = _expandedIdx == i;

              return FadeIn(
                delay: Duration(milliseconds: 300 + i * 60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: _CategoryAccordion(
                    category: cat,
                    doas: items,
                    expanded: expanded,
                    dark: dark,
                    tt: tt,
                    onToggle: () =>
                        setState(() => _expandedIdx = expanded ? -1 : i),
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: S.s80)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Daily Hadith Card
// ─────────────────────────────────────────────────────────

class _DailyHadithCard extends StatelessWidget {
  const _DailyHadithCard({
    required this.hadith,
    required this.dark,
    required this.tt,
  });

  final Hadith hadith;
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

          // Quote
          Text(
            '"',
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
            hadith.text,
            style: tt.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontSize: 15,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
          const SizedBox(height: S.s12),
          Text(
            '— ${hadith.source}',
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

// ─────────────────────────────────────────────────────────
//  Daily Doa Card
// ─────────────────────────────────────────────────────────

class _DailyDoaCard extends StatelessWidget {
  const _DailyDoaCard({
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
                  _categoryLabel(doa.category),
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

          // Arabic
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

          // Translation
          Text(
            doa.translation,
            style: tt.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
          const SizedBox(height: S.s8),
          Text(
            '— ${doa.source}',
            style: tt.bodySmall?.copyWith(
              color: dark ? C.onDark3 : C.onLight3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Category Accordion
// ─────────────────────────────────────────────────────────

class _CategoryAccordion extends StatelessWidget {
  const _CategoryAccordion({
    required this.category,
    required this.doas,
    required this.expanded,
    required this.dark,
    required this.tt,
    required this.onToggle,
  });

  final DoaCategory category;
  final List<Doa> doas;
  final bool expanded;
  final bool dark;
  final TextTheme tt;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: S.s8),
      child: Column(
        children: [
          // ── Header row ──
          BounceTap(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: S.s16,
                vertical: S.s16,
              ),
              decoration: BoxDecoration(
                color: dark ? C.dark3 : C.light2,
                borderRadius: expanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
                border: Border.all(
                  color: expanded
                      ? (dark
                          ? C.primarySoft.withValues(alpha: 0.15)
                          : C.primary.withValues(alpha: 0.1))
                      : (dark ? C.dark4 : C.lightDivider),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: dark ? C.primaryGlow : C.primaryGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _categoryIcon(category),
                      size: 18,
                      color: dark ? C.primarySoft : C.primary,
                    ),
                  ),
                  const SizedBox(width: S.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categoryLabel(category),
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doas.length} doa',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: expanded ? 0.25 : 0,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded doa list ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Container(
                    decoration: BoxDecoration(
                      color: dark
                          ? C.dark2.withValues(alpha: 0.6)
                          : C.light3.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: dark
                            ? C.primarySoft.withValues(alpha: 0.1)
                            : C.primary.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (var j = 0; j < doas.length; j++) ...[
                          if (j > 0)
                            Divider(
                              height: 1,
                              color: dark ? C.dark4 : C.lightDivider,
                              indent: S.s16,
                              endIndent: S.s16,
                            ),
                          _DoaEntry(doa: doas[j], dark: dark, tt: tt),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Individual Doa Entry (inside accordion)
// ─────────────────────────────────────────────────────────

class _DoaEntry extends StatelessWidget {
  const _DoaEntry({
    required this.doa,
    required this.dark,
    required this.tt,
  });

  final Doa doa;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(S.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text
          Text(
            doa.arabic,
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

          // Translation
          Text(
            doa.translation,
            style: tt.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
          const SizedBox(height: S.s8),

          // Source
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              doa.source,
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark3 : C.onLight3,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────

String _categoryLabel(DoaCategory cat) => switch (cat) {
      DoaCategory.morningEvening => 'Morning & Evening',
      DoaCategory.afterSolat => 'After Solat',
      DoaCategory.protection => 'Protection',
      DoaCategory.dailyEssentials => 'Daily Essentials',
    };

IconData _categoryIcon(DoaCategory cat) => switch (cat) {
      DoaCategory.morningEvening => CupertinoIcons.sun_max,
      DoaCategory.afterSolat => CupertinoIcons.heart,
      DoaCategory.protection => CupertinoIcons.shield,
      DoaCategory.dailyEssentials => CupertinoIcons.star,
    };

