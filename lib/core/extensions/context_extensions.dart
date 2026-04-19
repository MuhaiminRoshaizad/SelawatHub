import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

/// Convenience extensions on [BuildContext] to reduce boilerplate.
extension BuildContextX on BuildContext {
  /// Whether the current theme brightness is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Shorthand for `Theme.of(context).textTheme`.
  TextTheme get tt => Theme.of(this).textTheme;

  /// The primary accent color (theme-aware).
  Color get accent => isDark ? C.primarySoft : C.primary;

  /// Muted text color (theme-aware).
  Color get muted => isDark ? C.onDark3 : C.onLight3;
}
