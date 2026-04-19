import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: S.page),
        child: Column(
          children: [
            const SizedBox(height: S.s48),

            // App icon
            FadeIn(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: C.primaryGlow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🕌', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),

            const SizedBox(height: S.s24),

            // App name
            FadeIn(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'SelawatHub',
                style: tt.headlineLarge?.copyWith(
                  color: dark ? C.onDark1 : C.onLight1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: S.s4),

            // Version
            FadeIn(
              delay: const Duration(milliseconds: 150),
              child: Text(
                'v1.0.0',
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),

            const SizedBox(height: S.s32),

            // Description
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'A beautiful app for counting selawat and zikir, tracking your progress, and growing together with your community.',
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: S.s40),

            // Made with love
            FadeIn(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Made with ❤️ in Malaysia',
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),

            const SizedBox(height: S.s24),

            // Menu rows
            FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  _MenuRow(
                    label: 'Privacy Policy',
                    dark: dark,
                    tt: tt,
                  ),
                  const SizedBox(height: S.s12),
                  _MenuRow(
                    label: 'Terms of Service',
                    dark: dark,
                    tt: tt,
                  ),
                ],
              ),
            ),

            const SizedBox(height: S.s48),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.dark,
    required this.tt,
  });

  final String label;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.s16, vertical: S.s16),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? C.darkDivider : C.lightDivider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: dark ? C.onDark1 : C.onLight1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: dark ? C.onDark3 : C.onLight3,
          ),
        ],
      ),
    );
  }
}
