import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/profile/privacy_policy_page.dart';
import 'package:selawathub/features/profile/terms_of_service_page.dart';

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
        padding: EdgeInsets.only(
          left: S.page,
          right: S.page,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
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
                'SelawatHub is your companion for daily selawat and zikir. '
                'Count your dhikr with a beautiful digital tasbih, track your '
                'streaks and progress over time, set personal daily goals, and '
                'grow together with your community through group features.',
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: S.s24),

            // Features list
            FadeIn(
              delay: const Duration(milliseconds: 250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureRow(icon: Icons.touch_app, label: 'Digital tasbih with multiple dhikr types', dark: dark, tt: tt),
                  const SizedBox(height: S.s12),
                  _FeatureRow(icon: Icons.edit_outlined, label: 'Manual count entry & custom dhikr', dark: dark, tt: tt),
                  const SizedBox(height: S.s12),
                  _FeatureRow(icon: Icons.bar_chart, label: 'Personal statistics & streak tracking', dark: dark, tt: tt),
                  const SizedBox(height: S.s12),
                  _FeatureRow(icon: Icons.flag, label: 'Configurable daily goals', dark: dark, tt: tt),
                  const SizedBox(height: S.s12),
                  _FeatureRow(icon: Icons.group, label: 'Group dhikr with leaderboards', dark: dark, tt: tt),
                  const SizedBox(height: S.s12),
                  _FeatureRow(icon: Icons.menu_book, label: 'Daily hadith collection', dark: dark, tt: tt),
                  const SizedBox(height: S.s12),
                  _FeatureRow(icon: Icons.person_outline, label: 'Guest mode — no account required', dark: dark, tt: tt),
                ],
              ),
            ),

            const SizedBox(height: S.s32),

            // Made by
            FadeIn(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Made by MuhaiminRoshaizad',
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
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                  ),
                  const SizedBox(height: S.s12),
                  _MenuRow(
                    label: 'Terms of Service',
                    dark: dark,
                    tt: tt,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TermsOfServicePage())),
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.dark,
    required this.tt,
  });

  final IconData icon;
  final String label;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: C.primary),
        const SizedBox(width: S.s12),
        Expanded(
          child: Text(
            label,
            style: tt.bodyMedium?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.dark,
    required this.tt,
    required this.onTap,
  });

  final String label;
  final bool dark;
  final TextTheme tt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
    );
  }
}
