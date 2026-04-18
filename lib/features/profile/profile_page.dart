import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final themeCtrl = ThemeController.of(context);

    return Stack(
      children: [
        ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 80),

          const SizedBox(height: S.s32),

          // Avatar + name
          FadeIn(
            delay: const Duration(milliseconds: 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: C.primaryGlow,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'AM',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: C.primarySoft,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: S.s16),
                  Text('Amin Muhaimin', style: tt.headlineMedium),
                  const SizedBox(height: S.s4),
                  Text('Striving for consistency ✨', style: tt.bodyMedium),
                  const SizedBox(height: S.s16),
                  SizedBox(
                    width: 150,
                    child: BounceTap(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: S.s8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.pencil,
                              size: 14,
                              color: dark ? C.onDark2 : C.onLight2,
                            ),
                            const SizedBox(width: S.s6),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: dark ? C.onDark2 : C.onLight2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // Stats
          FadeIn(
            delay: const Duration(milliseconds: 160),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: S.s20),
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light3,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _StatItem(value: '28,450', label: 'Total'),
                      VerticalDivider(width: 1, color: dark ? C.darkDivider : C.lightDivider),
                      _StatItem(value: '19 days', label: 'Streak'),
                      VerticalDivider(width: 1, color: dark ? C.darkDivider : C.lightDivider),
                      _StatItem(value: '45', label: 'Days Active'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: S.s32),

          // Group section
          _SectionTitle(text: 'Group', delay: 220),
          FadeIn(
            delay: const Duration(milliseconds: 260),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _InfoRow(icon: CupertinoIcons.person_3_fill, label: 'Group', value: 'SelawatHub Family', dark: dark),
                    _divider(dark),
                    _InfoRow(icon: CupertinoIcons.number, label: 'Code', value: 'SLWT-7861', dark: dark),
                    _divider(dark),
                    _InfoRow(
                      icon: CupertinoIcons.star_fill,
                      label: 'Role',
                      value: 'Leader',
                      dark: dark,
                      valueColor: C.gold,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: S.s24),

          // Settings
          _SectionTitle(text: 'Settings', delay: 320),
          FadeIn(
            delay: const Duration(milliseconds: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeCtrl,
                      builder: (context, mode, child) => _ToggleRow(
                        icon: CupertinoIcons.moon_fill,
                        label: 'Dark Mode',
                        value: mode == ThemeMode.dark,
                        dark: dark,
                        onChanged: (v) =>
                            themeCtrl.value = v ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                    _divider(dark),
                    _ToggleRow(
                      icon: CupertinoIcons.bell_fill,
                      label: 'Notifications',
                      value: true,
                      dark: dark,
                      onChanged: (_) {},
                    ),
                    _divider(dark),
                    _InfoRow(
                      icon: CupertinoIcons.globe,
                      label: 'Language',
                      value: 'English',
                      dark: dark,
                      trailing: Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: S.s24),

          // Sign out
          FadeIn(
            delay: const Duration(milliseconds: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: BounceTap(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: S.s16),
                  decoration: BoxDecoration(
                    color: dark ? C.dark3 : C.light2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: C.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: S.s16),

          // Version
          FadeIn(
            delay: const Duration(milliseconds: 460),
            child: Center(
              child: Text(
                'SelawatHub v1.0.0',
                style: tt.bodySmall,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
        ],
      ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FrostedBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page, vertical: S.s12),
              child: FadeIn(
                child: Text('Profile', style: tt.headlineLarge),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _divider(bool dark) => Divider(
        height: 1,
        indent: 52,
        color: dark ? C.darkDivider : C.lightDivider,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.delay});
  final String text;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(S.page + 4, 0, S.page, S.s12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: tt.titleMedium),
          const SizedBox(height: S.s4),
          Text(label, style: tt.bodySmall),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.dark,
    this.trailing,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool dark;
  final Widget? trailing;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: dark ? C.onDark3 : C.onLight3),
          const SizedBox(width: S.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodySmall),
                const SizedBox(height: S.s2),
                Text(value, style: tt.titleSmall?.copyWith(color: valueColor)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.dark,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final bool dark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: dark ? C.onDark3 : C.onLight3),
          const SizedBox(width: S.s16),
          Expanded(child: Text(label, style: tt.titleSmall)),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
