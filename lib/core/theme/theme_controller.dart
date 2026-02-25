import 'package:flutter/material.dart';

class ThemeController extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const ThemeController({
    super.key,
    required ValueNotifier<ThemeMode> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final ThemeController? result =
        context.dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(result != null, 'No ThemeController found in context');
    return result!.notifier!;
  }
}

