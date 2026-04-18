import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/doa_api_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/hadith/doa_category_page.dart';
import 'package:selawathub/features/hadith/sources_page.dart';
import 'package:selawathub/features/hadith/models/doa.dart';

// ─────────────────────────────────────────────────────────
//  Daily Page — Hadith, Doa, Adkar, Post-Salaah from API
// ─────────────────────────────────────────────────────────

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});
  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  final _api = DoaApiService.instance;

  List<NawawiHadith> _hadiths = [];
  List<Doa> _duas = [];
  List<DailyAdkar> _adkar = [];
  List<PostSalaahZikr> _postSalaah = [];

  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    final results = await Future.wait([
      _api.fetchHadiths(),
      _api.fetchDuas(),
      _api.fetchDailyAdkar(),
      _api.fetchPostSalaah(),
    ]);

    final hadiths = results[0] as List<NawawiHadith>;
    final duas = results[1] as List<Doa>;
    final adkar = results[2] as List<DailyAdkar>;
    final postSalaah = results[3] as List<PostSalaahZikr>;

    if (!mounted) return;

    if (hadiths.isEmpty && duas.isEmpty && adkar.isEmpty && postSalaah.isEmpty) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    setState(() {
      _hadiths = hadiths;
      _duas = duas;
      _adkar = adkar;
      _postSalaah = postSalaah;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    if (_loading) return _LoadingView(dark: dark);
    if (_error) return _ErrorView(dark: dark, tt: tt, onRetry: _fetchAll);

    final dayIndex = DateTime.now().day;
    final todayHadith =
        _hadiths.isNotEmpty ? _hadiths[dayIndex % _hadiths.length] : null;
    final todayDoa = _duas.isNotEmpty ? _duas[dayIndex % _duas.length] : null;

    // Group duas by category
    final grouped = <String, List<Doa>>{};
    for (final d in _duas) {
      final cat = d.category.isNotEmpty ? d.category : 'other';
      grouped.putIfAbsent(cat, () => []).add(d);
    }
    final categories = grouped.keys.toList()..sort();

    return Stack(
      children: [
        CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 100),

                  // ── Daily Hadith Card ──
                  if (todayHadith != null)
                    FadeIn(
                      delay: const Duration(milliseconds: 80),
                      child: _DailyHadithCard(
                          hadith: todayHadith, dark: dark, tt: tt),
                    ),

                  const SizedBox(height: S.s12),

                  // ── Daily Doa Card ──
                  if (todayDoa != null)
                    FadeIn(
                      delay: const Duration(milliseconds: 160),
                      child:
                          _DailyDoaCard(doa: todayDoa, dark: dark, tt: tt),
                    ),

                  const SizedBox(height: S.s32),

                  // ── Daily Adkar Title ──
                  if (_adkar.isNotEmpty) ...[
                    FadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: Row(
                        children: [
                          Text('Daily Adkar', style: tt.titleLarge),
                          const SizedBox(width: S.s8),
                          GestureDetector(
                            onTap: () => _showSourceInfoSheet(
                              context: context,
                              title: 'Daily Adkar',
                              sourceName: 'Daily Adkar',
                              description:
                                  'Morning & evening remembrance (أذكار) to be '
                                  'recited daily as part of a Muslim\'s spiritual routine.',
                              endpoint: '/dailyAdkar',
                              accentColor: C.primary,
                            ),
                            child: Icon(
                              CupertinoIcons.info_circle,
                              size: 18,
                              color: dark ? C.onDark2 : C.onLight2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: S.s4),
                    FadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: Text(
                        'Morning & evening remembrance',
                        style: tt.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: S.s12),
                  ],
                ],
              ),
            ),
          ),

          // ── Daily Adkar horizontal list (full-width) ──
          if (_adkar.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 300),
                child: _HorizontalAdkarList(
                    items: _adkar, dark: dark, tt: tt),
              ),
            ),

          // ── Post-Salaah section ──
          if (_postSalaah.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: S.s32),
                    FadeIn(
                      delay: const Duration(milliseconds: 360),
                      child: Row(
                        children: [
                          Text('Post-Salaah', style: tt.titleLarge),
                          const SizedBox(width: S.s8),
                          GestureDetector(
                            onTap: () => _showSourceInfoSheet(
                              context: context,
                              title: 'Post-Salaah',
                              sourceName: 'Post-Salaah Zikr',
                              description:
                                  'Remembrance and supplications to be recited '
                                  'after the five daily prayers.',
                              endpoint: '/postSalaah',
                              accentColor: C.primary,
                            ),
                            child: Icon(
                              CupertinoIcons.info_circle,
                              size: 18,
                              color: dark ? C.onDark2 : C.onLight2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: S.s4),
                    FadeIn(
                      delay: const Duration(milliseconds: 360),
                      child: Text(
                        'Remembrance after prayer',
                        style: tt.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: S.s12),
                  ],
                ),
              ),
            ),

          // ── Post-Salaah horizontal list (full-width) ──
          if (_postSalaah.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 420),
                child: _HorizontalPostSalaahList(
                    items: _postSalaah, dark: dark, tt: tt),
              ),
            ),

          // ── Doa Collection header ──
          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: S.s32),
                    FadeIn(
                      delay: const Duration(milliseconds: 480),
                      child: Row(
                        children: [
                          Text('Doa Collection', style: tt.titleLarge),
                          const SizedBox(width: S.s8),
                          GestureDetector(
                            onTap: () => _showSourceInfoSheet(
                              context: context,
                              title: 'Doa Collection',
                              sourceName: 'Useful Duas Collection',
                              description:
                                  '102 supplications sourced from the Quran & Sunnah, '
                                  'categorized by topic for easy reference.',
                              endpoint: '/usefulDuas',
                              accentColor: C.primary,
                            ),
                            child: Icon(
                              CupertinoIcons.info_circle,
                              size: 18,
                              color: dark ? C.onDark2 : C.onLight2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: S.s4),
                    FadeIn(
                      delay: const Duration(milliseconds: 480),
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

          // ── Category grid ──
          if (categories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: S.s12,
                  crossAxisSpacing: S.s12,
                  childAspectRatio: 1.55,
                ),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  final items = grouped[cat]!;

                  return FadeIn(
                    delay: Duration(milliseconds: 540 + i * 50),
                    child: _CategoryCard(
                      category: cat,
                      count: items.length,
                      dark: dark,
                      tt: tt,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DoaCategoryPage(
                            category: cat,
                            doas: items,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
          ),
        ],
      ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FrostedBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page, vertical: S.s16),
              child: FadeIn(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily', style: tt.headlineLarge),
                          const SizedBox(height: S.s4),
                          Text(
                            'Your spiritual companion',
                            style: tt.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    BounceTap(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SourcesPage(),
                        ),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: dark ? C.dark3 : C.light3,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.info_circle,
                          size: 16,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Loading skeleton
// ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.page),
        child: ListView(
          children: [
            const SizedBox(height: S.s16),
            _SkeletonBox(width: 120, height: 28, dark: dark),
            const SizedBox(height: S.s4),
            _SkeletonBox(width: 180, height: 16, dark: dark),
            const SizedBox(height: S.s24),
            _SkeletonBox(width: double.infinity, height: 200, dark: dark),
            const SizedBox(height: S.s12),
            _SkeletonBox(width: double.infinity, height: 180, dark: dark),
            const SizedBox(height: S.s32),
            _SkeletonBox(width: 140, height: 22, dark: dark),
            const SizedBox(height: S.s12),
            _SkeletonBox(width: double.infinity, height: 120, dark: dark),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.dark,
  });
  final double width;
  final double height;
  final bool dark;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final opacity = 0.08 + _ctrl.value * 0.08;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.dark ? C.onDark1 : C.onLight1)
                .withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Error view with retry
// ─────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.dark,
    required this.tt,
    required this.onRetry,
  });
  final bool dark;
  final TextTheme tt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(S.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.wifi_slash,
                size: 48,
                color: dark ? C.onDark3 : C.onLight3,
              ),
              const SizedBox(height: S.s16),
              Text(
                'Unable to load',
                style: tt.titleMedium?.copyWith(
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
              const SizedBox(height: S.s8),
              Text(
                'Check your connection and try again',
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                ),
              ),
              const SizedBox(height: S.s24),
              BounceTap(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.s24, vertical: S.s12),
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: C.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                  _capitalize(doa.category),
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

// ─────────────────────────────────────────────────────────
//  Horizontal Adkar List
// ─────────────────────────────────────────────────────────

class _HorizontalAdkarList extends StatelessWidget {
  const _HorizontalAdkarList({
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
        itemBuilder: (_, i) => _ZikrPreviewCard(
          title: items[i].title,
          arabic: items[i].arabic,
          times: items[i].times,
          dark: dark,
          tt: tt,
          accentColor: C.primary,
          accentSoft: C.primarySoft,
          accentGlow: C.primaryGlow,
          onTap: () => _showZikrDetailSheet(
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

class _HorizontalPostSalaahList extends StatelessWidget {
  const _HorizontalPostSalaahList({
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
        itemBuilder: (_, i) => _ZikrPreviewCard(
          title: items[i].title,
          arabic: items[i].arabic,
          times: items[i].times,
          dark: dark,
          tt: tt,
          accentColor: C.gold,
          accentSoft: C.goldSoft,
          accentGlow: C.goldGlow,
          onTap: () => _showZikrDetailSheet(
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

// ─────────────────────────────────────────────────────────
//  Shared Preview Card (compact, used for both adkar & post-salaah)
// ─────────────────────────────────────────────────────────

class _ZikrPreviewCard extends StatelessWidget {
  const _ZikrPreviewCard({
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

// ─────────────────────────────────────────────────────────
//  Zikr / Adkar Detail Bottom Sheet
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────
//  Source info bottom sheet
// ─────────────────────────────────────────────────────────

void _showSourceInfoSheet({
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

      // Endpoint
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(S.s16),
        decoration: BoxDecoration(
          color: dark
              ? C.dark4.withValues(alpha: 0.5)
              : C.light3.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.link,
              size: 14,
              color: dark ? C.onDark2 : C.onLight2,
            ),
            const SizedBox(width: S.s8),
            Text(
              endpoint,
              style: tt.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

void _showZikrDetailSheet({
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

// ─────────────────────────────────────────────────────────
//  Category Card (grid item → taps to detail page)
// ─────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
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
                _categoryIcon(category),
                size: 18,
                color: dark ? C.primarySoft : C.primary,
              ),
            ),
            const Spacer(),
            Text(
              _capitalize(category),
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

// ─────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

IconData _categoryIcon(String cat) => switch (cat) {
      'daily' => CupertinoIcons.sun_max,
      'prayer' => CupertinoIcons.heart,
      'protection' => CupertinoIcons.shield,
      'hardship' => CupertinoIcons.flame,
      'social' => CupertinoIcons.person_2,
      'family' => CupertinoIcons.house,
      'death' => CupertinoIcons.moon_stars,
      'ramadan' => CupertinoIcons.moon,
      'travel' => CupertinoIcons.airplane,
      _ => CupertinoIcons.star,
    };

