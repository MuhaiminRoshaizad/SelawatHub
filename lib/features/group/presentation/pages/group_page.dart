import 'package:flutter/material.dart';
import 'package:selawathub/core/widgets/app_background.dart';
import 'package:selawathub/core/widgets/blur_card.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('Group Progress', style: textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Track shared momentum, member activity, and pending approvals.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          const BlurCard(
            child: _HighlightTile(
              title: 'Today Group Total',
              value: '85,121',
              subtitle: '24 approved members active',
            ),
          ),
          const SizedBox(height: 12),
          const BlurCard(
            child: _HighlightTile(
              title: 'Pending Join Requests',
              value: '6',
              subtitle: 'Leader can approve or reject',
            ),
          ),
          const SizedBox(height: 12),
          const BlurCard(
            child: _HighlightTile(
              title: 'Your Contribution',
              value: '1,240',
              subtitle: '1.45% of today total',
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

