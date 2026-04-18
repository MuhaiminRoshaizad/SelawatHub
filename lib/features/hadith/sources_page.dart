import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';

// ─────────────────────────────────────────────────────────
//  Sources & Credits Page
// ─────────────────────────────────────────────────────────

class SourcesPage extends StatelessWidget {
  const SourcesPage({super.key});

  static const _apiBase = 'https://dua-data-api.vercel.app/';

  static const _sources = [
    _SourceData(
      name: 'Forty Nawawi Hadiths',
      description:
          '40 authentic hadiths compiled by Imam An-Nawawi, covering the '
          'foundations of Islamic law, worship, and conduct.',
      usedFor: 'Daily Hadith section',
      endpoint: '/fortyNawawi',
    ),
    _SourceData(
      name: 'Useful Duas Collection',
      description:
          '102 supplications sourced from the Quran & Sunnah, categorized '
          'by topic for easy reference.',
      usedFor: 'Daily Doa & Doa Collection sections',
      endpoint: '/usefulDuas',
    ),
    _SourceData(
      name: 'Daily Adkar',
      description:
          'Morning & evening remembrance (أذكار) to be recited daily as '
          'part of a Muslim\'s spiritual routine.',
      usedFor: 'Daily Adkar section',
      endpoint: '/dailyAdkar',
    ),
    _SourceData(
      name: 'Post-Salaah Zikr',
      description:
          'Remembrance and supplications to be recited after the five '
          'daily prayers.',
      usedFor: 'Post-Salaah section',
      endpoint: '/postSalaah',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // Top spacer for frosted bar
              SizedBox(height: MediaQuery.of(context).padding.top + 56),

              // ── API badge ──
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(S.page, S.s24, S.page, S.s8),
                child: FadeIn(
                  child: GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse(_apiBase),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: S.s16,
                        vertical: S.s12,
                      ),
                      decoration: BoxDecoration(
                        color: C.primaryGlow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dark
                              ? C.primarySoft.withValues(alpha: 0.15)
                              : C.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.globe,
                                size: 16,
                                color: dark ? C.primarySoft : C.primary,
                              ),
                              const SizedBox(width: S.s8),
                              Text(
                                'Naikiyah Dua Data API',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: dark ? C.primarySoft : C.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: S.s8),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.link,
                                size: 12,
                                color: (dark ? C.primarySoft : C.primary)
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: S.s6),
                              Flexible(
                                child: Text(
                                  _apiBase,
                                  style: tt.bodySmall?.copyWith(
                                    color: dark ? C.primarySoft : C.primary,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        (dark ? C.primarySoft : C.primary)
                                            .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: S.s4),
                              Icon(
                                CupertinoIcons.arrow_up_right_square,
                                size: 12,
                                color: (dark ? C.primarySoft : C.primary)
                                    .withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Source cards ──
              ...List.generate(_sources.length, (i) {
                final src = _sources[i];
                return FadeIn(
                  delay: Duration(milliseconds: 100 + i * 80),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        S.page, S.s12, S.page, 0),
                    child: _SourceCard(source: src, dark: dark, tt: tt),
                  ),
                );
              }),

              // ── Disclaimer ──
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(S.page, S.s32, S.page, 0),
                child: FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(S.s16),
                    decoration: BoxDecoration(
                      color: dark
                          ? C.dark3.withValues(alpha: 0.5)
                          : C.light3.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dark
                            ? C.dark4.withValues(alpha: 0.5)
                            : C.lightDivider.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.book,
                          size: 16,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                        const SizedBox(width: S.s12),
                        Expanded(
                          child: Text(
                            'All content is sourced from open Islamic API '
                            'databases. We do not claim ownership of any '
                            'religious content.',
                            style: tt.bodySmall?.copyWith(
                              color: dark ? C.onDark2 : C.onLight2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom spacer ──
              SizedBox(
                height:
                    MediaQuery.of(context).padding.bottom + 56 + S.s24,
              ),
            ],
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: S.s16),
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
                          'Sources & Credits',
                          style: tt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
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
//  Source data model
// ─────────────────────────────────────────────────────────

class _SourceData {
  const _SourceData({
    required this.name,
    required this.description,
    required this.usedFor,
    required this.endpoint,
  });

  final String name;
  final String description;
  final String usedFor;
  final String endpoint;
}

// ─────────────────────────────────────────────────────────
//  Source card widget
// ─────────────────────────────────────────────────────────

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.dark,
    required this.tt,
  });

  final _SourceData source;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(S.s16),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? C.dark4.withValues(alpha: 0.6)
              : C.lightDivider.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            source.name,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
          const SizedBox(height: S.s8),

          // Description
          Text(
            source.description,
            style: tt.bodySmall?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: S.s12),

          // Used for badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: S.s8,
              vertical: S.s4,
            ),
            decoration: BoxDecoration(
              color: C.primaryGlow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Used for: ${source.usedFor}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: dark ? C.primarySoft : C.primary,
              ),
            ),
          ),
          const SizedBox(height: S.s8),

          // Endpoint — tappable link
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse('https://dua-data-api.vercel.app/api${source.endpoint}'),
              mode: LaunchMode.externalApplication,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: S.s8,
                vertical: S.s4,
              ),
              decoration: BoxDecoration(
                color: dark
                    ? C.primarySoft.withValues(alpha: 0.06)
                    : C.primary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: dark
                      ? C.primarySoft.withValues(alpha: 0.12)
                      : C.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.link,
                    size: 11,
                    color: dark ? C.primarySoft : C.primary,
                  ),
                  const SizedBox(width: S.s4),
                  Text(
                    source.endpoint,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                      color: dark ? C.primarySoft : C.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: (dark ? C.primarySoft : C.primary)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: S.s4),
                  Icon(
                    CupertinoIcons.arrow_up_right_square,
                    size: 10,
                    color: (dark ? C.primarySoft : C.primary)
                        .withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
