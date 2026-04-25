import 'package:flutter/material.dart';
import 'package:selawathub/core/services/settings_service.dart';

/// Controls the active locale for the app.
///
/// Mirrors the `ThemeController` pattern: a `ValueNotifier` owned by the
/// root state, exposed via an `InheritedNotifier` so any widget can change
/// it. Persisted in `SettingsService.localeMode`:
///
///  * `0` — follow system (resolves to `ms` on Malay devices, `en` otherwise)
///  * `1` — force English
///  * `2` — force Bahasa Melayu
///
/// `currentLocale` returns the *resolved* `Locale` (never null) — useful
/// when you need to know what's actually being shown right now (e.g. for
/// `intl` date formatting or the language picker's "system → English"
/// hint).
class LocaleMode {
  static const int system = 0;
  static const int english = 1;
  static const int malay = 2;
}

/// Resolves a saved [LocaleMode] integer into the actual [Locale] to use.
/// Pass the device locale so "System default" can fall back appropriately.
Locale resolveLocale(int mode, Locale deviceLocale) {
  if (mode == LocaleMode.english) return const Locale('en');
  if (mode == LocaleMode.malay) return const Locale('ms');
  // System: respect device language if it's one we support.
  if (deviceLocale.languageCode == 'ms') return const Locale('ms');
  return const Locale('en');
}

class LocaleController extends InheritedNotifier<ValueNotifier<int>> {
  const LocaleController({
    super.key,
    required ValueNotifier<int> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<int> of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<LocaleController>();
    assert(result != null, 'No LocaleController found');
    return result!.notifier!;
  }

  /// Persists the new mode and notifies listeners.
  static void set(BuildContext context, int mode) {
    SettingsService.localeMode = mode;
    of(context).value = mode;
  }
}
