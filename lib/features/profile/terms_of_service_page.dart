import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const _lastUpdated = '25 April 2026';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    final sections = <(String, String)>[
      (l.termsIntroTitle, l.termsIntroBody),
      (l.terms1Title, l.terms1Body),
      (l.terms2Title, l.terms2Body),
      (l.terms3Title, l.terms3Body),
      (l.terms4Title, l.terms4Body),
      (l.terms5Title, l.terms5Body),
      (l.terms6Title, l.terms6Body),
      (l.terms7Title, l.terms7Body),
      (l.terms8Title, l.terms8Body),
      (l.terms9Title, l.terms9Body),
      (l.terms10Title, l.terms10Body),
      (l.terms11Title, l.terms11Body),
      (l.terms12Title, l.terms12Body),
    ];

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(title: Text(l.termsTitle)),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: S.page,
          right: S.page,
          top: S.s24,
          bottom: S.s24 + MediaQuery.of(context).padding.bottom,
        ),
        child: FadeIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.termsTitle,
                style: tt.headlineSmall?.copyWith(
                  color: dark ? C.onDark1 : C.onLight1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: S.s4),
              Text(
                l.legalLastUpdated(_lastUpdated),
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(height: S.s24),
              for (final s in sections) _section(tt, dark, s.$1, s.$2),
              const SizedBox(height: S.s48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(TextTheme tt, bool dark, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: S.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: dark ? C.onDark1 : C.onLight1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: S.s8),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
