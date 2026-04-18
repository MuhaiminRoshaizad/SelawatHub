import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final d = brightness == Brightness.dark;
    final bg = d ? C.dark1 : C.light1;
    final surface = d ? C.dark3 : C.light2;
    final divider = d ? C.darkDivider : C.lightDivider;
    final t1 = d ? C.onDark1 : C.onLight1;
    final t2 = d ? C.onDark2 : C.onLight2;
    final t3 = d ? C.onDark3 : C.onLight3;
    final accent = d ? C.primarySoft : C.primary;

    final text = TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: t1, letterSpacing: -0.5, height: 1.15),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t1, height: 1.2),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: t1),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t1),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t1),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: t2, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: t2, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: t3),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accent),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: t3, letterSpacing: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: C.white,
        secondary: C.gold,
        onSecondary: C.dark1,
        surface: surface,
        onSurface: t1,
        error: C.error,
        onError: C.white,
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: C.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: t1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: d ? C.dark4 : C.light3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: t3, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: C.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t1,
          side: BorderSide(color: divider),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 0),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? C.white : t3),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent : divider),
      ),
    );
  }
}

/// Provides ThemeMode to the widget tree via InheritedNotifier.
class ThemeController extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const ThemeController({
    super.key,
    required ValueNotifier<ThemeMode> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(result != null, 'No ThemeController found');
    return result!.notifier!;
  }
}
