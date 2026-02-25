import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/analytics/presentation/pages/analytics_page.dart';
import 'package:selawathub/features/counter/presentation/pages/counter_page.dart';
import 'package:selawathub/features/group/presentation/pages/group_page.dart';
import 'package:selawathub/features/profile/presentation/pages/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    CounterPage(),
    GroupPage(),
    AnalyticsPage(),
    ProfilePage(),
  ];

  static const List<({IconData icon, IconData activeIcon, String label})>
      _tabs = [
    (
      icon: CupertinoIcons.plus_circle,
      activeIcon: CupertinoIcons.plus_circle_fill,
      label: 'Counter',
    ),
    (
      icon: CupertinoIcons.person_3,
      activeIcon: CupertinoIcons.person_3_fill,
      label: 'Group',
    ),
    (
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Analytics',
    ),
    (
      icon: CupertinoIcons.person_crop_circle,
      activeIcon: CupertinoIcons.person_crop_circle_fill,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 3
          ? _LiquidSignOutButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign out tapped')),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: _LiquidTabBar(
            currentIndex: _index,
            tabs: _tabs,
            isDark: isDark,
            onTap: (value) => setState(() => _index = value),
          ),
        ),
      ),
    );
  }
}

class _LiquidSignOutButton extends StatelessWidget {
  const _LiquidSignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: isDark
              ? AppColors.darkCard.withValues(alpha: 0.7)
              : AppColors.white.withValues(alpha: 0.76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: AppColors.white.withValues(alpha: isDark ? 0.2 : 0.78),
              width: 1.1,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.square_arrow_right,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidTabBar extends StatelessWidget {
  const _LiquidTabBar({
    required this.currentIndex,
    required this.tabs,
    required this.isDark,
    required this.onTap,
  });

  final int currentIndex;
  final List<({IconData icon, IconData activeIcon, String label})> tabs;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: isDark ? AppColors.navGlassDark : AppColors.navGlassLight,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? AppColors.navBorderDark : AppColors.navBorderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 10),
                color: (isDark ? AppColors.ink : AppColors.ocean)
                    .withValues(alpha: 0.14),
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: i == currentIndex
                            ? AppColors.ocean.withValues(alpha: 0.16)
                            : AppColors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            i == currentIndex ? tabs[i].activeIcon : tabs[i].icon,
                            size: 20,
                            color: i == currentIndex
                                ? (isDark ? AppColors.darkInk : AppColors.ink)
                                : (isDark
                                    ? AppColors.darkSlate
                                    : AppColors.slate),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: i == currentIndex
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == currentIndex
                                  ? (isDark ? AppColors.darkInk : AppColors.ink)
                                  : (isDark
                                      ? AppColors.darkSlate
                                      : AppColors.slate),
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
    );
  }
}
