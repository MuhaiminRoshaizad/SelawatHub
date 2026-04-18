import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
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
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  color: dark ? C.dark1.withValues(alpha: 0.75) : C.light1.withValues(alpha: 0.8),
                ),
              ),
            ),
            shape: Border(
              bottom: BorderSide(
                color: dark ? C.dark4.withValues(alpha: 0.5) : C.lightDivider.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 20,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
            ),
            title: Text(
              _capitalize(category),
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: S.s16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // ── Doa list ──
          SliverList.separated(
            itemCount: doas.length,
            separatorBuilder: (_, i) => Divider(
              height: 1,
              color: dark ? C.dark4 : C.lightDivider,
              indent: S.page,
              endIndent: S.page,
            ),
            itemBuilder: (_, i) {
              final doa = doas[i];
              return FadeIn(
                delay: Duration(milliseconds: i.clamp(0, 8) * 50),
                child: _DoaCard(
                  doa: doa,
                  index: i + 1,
                  dark: dark,
                  tt: tt,
                ),
              );
            },
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
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
