import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.plus_circle),
            selectedIcon: Icon(CupertinoIcons.plus_circle_fill),
            label: 'Counter',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person_3),
            selectedIcon: Icon(CupertinoIcons.person_3_fill),
            label: 'Group',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.chart_bar),
            selectedIcon: Icon(CupertinoIcons.chart_bar_fill),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person_crop_circle),
            selectedIcon: Icon(CupertinoIcons.person_crop_circle_fill),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

