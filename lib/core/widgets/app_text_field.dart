import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

/// Returns the standard app InputDecoration (filled, rounded, dark-aware).
InputDecoration appInputDecoration({
  required BuildContext context,
  String? hintText,
  bool showCounter = false,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: dark ? C.onDark3 : C.onLight3),
    filled: true,
    fillColor: dark ? C.dark4 : C.light3,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    counterStyle: showCounter
        ? TextStyle(color: dark ? C.onDark3 : C.onLight3)
        : const TextStyle(height: 0, fontSize: 0),
  );
}
