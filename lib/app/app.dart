import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/features/auth/welcome_page.dart';

class SelawatHubApp extends StatefulWidget {
  const SelawatHubApp({super.key});

  @override
  State<SelawatHubApp> createState() => _SelawatHubAppState();
}

class _SelawatHubAppState extends State<SelawatHubApp> {
  final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      notifier: _themeMode,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, child) => MaterialApp(
          title: 'SelawatHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const WelcomePage(),
        ),
      ),
    );
  }
}
