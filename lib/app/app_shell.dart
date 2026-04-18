import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/counter/counter_page.dart';
import 'package:selawathub/features/group/group_page.dart';
import 'package:selawathub/features/stats/stats_page.dart';
import 'package:selawathub/features/hadith/hadith_page.dart';
import 'package:selawathub/features/profile/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  static const _pages = [
    CounterPage(),
    GroupPage(),
    StatsPage(),
    HadithPage(),
    ProfilePage(),
  ];

  static const _items = [
    (CupertinoIcons.circle_grid_3x3, CupertinoIcons.circle_grid_3x3_fill, 'Tasbih'),
    (CupertinoIcons.person_3, CupertinoIcons.person_3_fill, 'Group'),
    (CupertinoIcons.chart_bar, CupertinoIcons.chart_bar_fill, 'Stats'),
    (CupertinoIcons.book, CupertinoIcons.book_fill, 'Doa'),
    (CupertinoIcons.person, CupertinoIcons.person_fill, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: dark ? C.dark2 : C.light2,
          border: Border(
            top: BorderSide(
              color: dark ? C.darkDivider : C.lightDivider,
              width: 0.5,
            ),
          ),
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(5, (i) {
              final active = i == _tab;
              final (icon, activeIcon, label) = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            active ? activeIcon : icon,
                            key: ValueKey('$i-$active'),
                            size: 22,
                            color: active
                                ? (dark ? C.primarySoft : C.primary)
                                : (dark ? C.onDark3 : C.onLight3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active
                                ? (dark ? C.primarySoft : C.primary)
                                : (dark ? C.onDark3 : C.onLight3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
