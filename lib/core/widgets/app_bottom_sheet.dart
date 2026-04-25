import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

/// Lightweight bottom sheet with a drag handle auto-included.
/// Use for simple form-style sheets (text fields, confirmations, pickers).
///
/// ```dart
/// showAppFormSheet(
///   context: context,
///   builder: (ctx) => Column(children: [...]),
/// );
/// ```
Future<T?> showAppFormSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: dark ? C.dark2 : C.light1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: S.s12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: dark ? C.dark4 : C.lightDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: S.s8),
          builder(ctx),
        ],
      ),
    ),
  );
}

/// Standardised bottom sheet with a pinned header (drag handle, header row,
/// divider) and scrollable content beneath.  Every bottom sheet in the app
/// should use this so the UX stays consistent.
///
/// ```dart
/// showAppBottomSheet(
///   context: context,
///   initialSize: 0.5,
///   headerChildren: [Text('Title')],
///   bodyChildren: [Text('Content')],
/// );
/// ```
void showAppBottomSheet({
  required BuildContext context,

  /// Widgets placed in the pinned header row (between left side and close
  /// button). Typically a title [Text] or badge + spacer combo.
  required List<Widget> headerChildren,

  /// Widgets placed inside the scrollable [ListView] below the divider.
  required List<Widget> bodyChildren,

  double initialSize = 0.5,
  double minSize = 0.3,
  double maxSize = 0.92,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      final bottomInset = MediaQuery.of(sheetCtx).padding.bottom;
      return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: dark ? C.dark2 : C.light2,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Pinned header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Column(
                children: [
                  const SizedBox(height: S.s12),

                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: dark ? C.dark4 : C.lightDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: S.s16),

                  // Header row
                  Row(
                    children: [
                      ...headerChildren,
                      const Spacer(),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: dark ? C.dark3 : C.light3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 14,
                            color: dark ? C.onDark3 : C.onLight3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: S.s20),

                  // Divider
                  Divider(
                    height: 1,
                    color: dark ? C.dark4 : C.lightDivider,
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                children: [
                  const SizedBox(height: S.s20),
                  ...bodyChildren,
                  SizedBox(height: bottomInset + 56 + S.s24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    },
  );
}
