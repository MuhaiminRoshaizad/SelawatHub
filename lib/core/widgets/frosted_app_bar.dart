import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';

/// Standardized frosted app bar with back button and title.
/// Wrap in Positioned(top: 0, left: 0, right: 0) when using in a Stack.
class FrostedAppBar extends StatelessWidget {
  const FrostedAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return FrostedBar(
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.s16),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 20,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
            ),
            if (trailing != null) ?trailing,
          ],
        ),
      ),
    );
  }
}
