import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

enum SectionHeaderStyle { label, title }

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.text,
    this.subtitle,
    this.style = SectionHeaderStyle.label,
  });

  final String text;
  final String? subtitle;
  final SectionHeaderStyle style;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (style == SectionHeaderStyle.title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(S.page, S.s4, S.page, S.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: S.s2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Default: label style
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.page),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: dark ? C.onDark3 : C.onLight3,
        ),
      ),
    );
  }
}
