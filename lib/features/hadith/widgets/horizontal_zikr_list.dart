import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/hadith/models/doa.dart';
import 'package:selawathub/features/hadith/widgets/hadith_bottom_sheets.dart';
import 'package:selawathub/features/hadith/widgets/zikr_preview_card.dart';

// ─────────────────────────────────────────────────────────
//  Horizontal Adkar List
// ─────────────────────────────────────────────────────────

class HorizontalAdkarList extends StatelessWidget {
  const HorizontalAdkarList({
    super.key,
    required this.items,
    required this.dark,
    required this.tt,
  });

  final List<DailyAdkar> items;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: S.page),
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, i) => const SizedBox(width: S.s12),
        itemBuilder: (_, i) => ZikrPreviewCard(
          title: items[i].title,
          arabic: items[i].arabic,
          times: items[i].times,
          dark: dark,
          tt: tt,
          accentColor: C.primary,
          accentSoft: C.primarySoft,
          accentGlow: C.primaryGlow,
          onTap: () => showZikrDetailSheet(
            context: context,
            title: items[i].title,
            arabic: items[i].arabic,
            translation: items[i].translation,
            transliteration: items[i].transliteration,
            times: items[i].times,
            benefit: items[i].benefit,
            accentColor: C.primary,
            accentSoft: C.primarySoft,
            accentGlow: C.primaryGlow,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Horizontal Post-Salaah List
// ─────────────────────────────────────────────────────────

class HorizontalPostSalaahList extends StatelessWidget {
  const HorizontalPostSalaahList({
    super.key,
    required this.items,
    required this.dark,
    required this.tt,
  });

  final List<PostSalaahZikr> items;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: S.page),
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, i) => const SizedBox(width: S.s12),
        itemBuilder: (_, i) => ZikrPreviewCard(
          title: items[i].title,
          arabic: items[i].arabic,
          times: items[i].times,
          dark: dark,
          tt: tt,
          accentColor: C.gold,
          accentSoft: C.goldSoft,
          accentGlow: C.goldGlow,
          onTap: () => showZikrDetailSheet(
            context: context,
            title: items[i].title,
            arabic: items[i].arabic,
            translation: items[i].translation,
            transliteration: items[i].transliteration,
            times: items[i].times,
            benefit: items[i].benefit,
            accentColor: C.gold,
            accentSoft: C.goldSoft,
            accentGlow: C.goldGlow,
          ),
        ),
      ),
    );
  }
}
