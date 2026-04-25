import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _lastUpdated = '25 April 2026';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    final sections = <(String, String)>[
      (l.privacyIntroTitle, l.privacyIntroBody),
      (l.privacy1Title, l.privacy1Body),
      (l.privacy2Title, l.privacy2Body),
      (l.privacy3Title, l.privacy3Body),
      (l.privacy4Title, l.privacy4Body),
      (l.privacy5Title, l.privacy5Body),
      (l.privacy6Title, l.privacy6Body),
      (l.privacy7Title, l.privacy7Body),
      (l.privacy8Title, l.privacy8Body),
      (l.privacy9Title, l.privacy9Body),
      (l.privacy10Title, l.privacy10Body),
    ];

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(title: Text(l.privacyTitle)),
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
                l.privacyTitle,
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
