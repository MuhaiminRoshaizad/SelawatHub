import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/doa_api_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/hadith/doa_category_page.dart';
import 'package:selawathub/features/hadith/sources_page.dart';
import 'package:selawathub/features/hadith/models/doa.dart';
import 'package:selawathub/features/hadith/widgets/category_card.dart';
import 'package:selawathub/features/hadith/widgets/daily_doa_card.dart';
import 'package:selawathub/features/hadith/widgets/daily_hadith_card.dart';
import 'package:selawathub/features/hadith/widgets/hadith_bottom_sheets.dart';
import 'package:selawathub/features/hadith/widgets/hadith_error_view.dart';
import 'package:selawathub/features/hadith/widgets/hadith_loading_view.dart';
import 'package:selawathub/features/hadith/widgets/horizontal_zikr_list.dart';

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

    if (_loading) return HadithLoadingView(dark: dark);
    if (_error) return HadithErrorView(dark: dark, tt: tt, onRetry: _fetchAll);

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
                      child: DailyHadithCard(
                          hadith: todayHadith, dark: dark, tt: tt),
                    ),

                  const SizedBox(height: S.s12),

                  // ── Daily Doa Card ──
                  if (todayDoa != null)
                    FadeIn(
                      delay: const Duration(milliseconds: 160),
                      child:
                          DailyDoaCard(doa: todayDoa, dark: dark, tt: tt),
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
                            onTap: () => showSourceInfoSheet(
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
                child: HorizontalAdkarList(
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
                            onTap: () => showSourceInfoSheet(
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
                child: HorizontalPostSalaahList(
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
                            onTap: () => showSourceInfoSheet(
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
                    child: CategoryCard(
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

