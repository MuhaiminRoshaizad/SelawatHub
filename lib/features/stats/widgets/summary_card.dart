import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.dark,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(S.s16),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: S.s12),
          Text(value, style: tt.titleLarge),
          const SizedBox(height: S.s2),
          Text(label, style: tt.bodySmall),
        ],
      ),
    );
  }
}
