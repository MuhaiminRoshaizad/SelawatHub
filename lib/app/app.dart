import 'dart:async';
import 'package:flutter/material.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/features/auth/onboarding_page.dart';
import 'package:selawathub/features/auth/reset_password_page.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelawatHubApp extends StatefulWidget {
  const SelawatHubApp({super.key});

  @override
  State<SelawatHubApp> createState() => _SelawatHubAppState();
}

class _SelawatHubAppState extends State<SelawatHubApp> {
  late final ValueNotifier<ThemeMode> _themeMode;
  final _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<AuthState>? _authSub;

  static const _modeMap = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  @override
  void initState() {
    super.initState();
    final saved = SettingsService.themeMode.clamp(0, 2);
    _themeMode = ValueNotifier<ThemeMode>(_modeMap[saved]);
    _themeMode.addListener(_persistTheme);

    _authSub = AuthService.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        _navKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (_) => false,
        );
      } else if (state.event == AuthChangeEvent.signedOut) {
        // Wipe any cached personal data so the next user (or guest) doesn't
        // briefly see the previous user's profile/stats on first load.
        SettingsService.clearCachedProfile();
        _navKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomePage()),
          (_) => false,
        );
      }
    });
  }

  void _persistTheme() {
    SettingsService.themeMode = _modeMap.indexOf(_themeMode.value);
  }

  @override
  void dispose() {
    _authSub?.cancel();
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
          navigatorKey: _navKey,
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
