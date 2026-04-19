import 'package:flutter/material.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/features/auth/onboarding_page.dart';

class SelawatHubApp extends StatefulWidget {
  const SelawatHubApp({super.key});

  @override
  State<SelawatHubApp> createState() => _SelawatHubAppState();
}

class _SelawatHubAppState extends State<SelawatHubApp> {
  late final ValueNotifier<ThemeMode> _themeMode;

  static const _modeMap = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  @override
  void initState() {
    super.initState();
    final saved = SettingsService.themeMode.clamp(0, 2);
    _themeMode = ValueNotifier<ThemeMode>(_modeMap[saved]);
    _themeMode.addListener(_persistTheme);
  }

  void _persistTheme() {
    SettingsService.themeMode = _modeMap.indexOf(_themeMode.value);
  }

  @override
  void dispose() {
    _themeMode.removeListener(_persistTheme);
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = SupabaseService.isAuthenticated;

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
          home: isLoggedIn ? const AppShell() : const OnboardingPage(),
        ),
      ),
    );
  }
}
