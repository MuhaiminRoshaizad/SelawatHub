import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/widgets/app_background.dart';
import 'package:selawathub/core/widgets/blur_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'A focused dashboard for trends, streaks, and contribution quality.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          const BlurCard(child: _TrendCard()),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: BlurCard(
                  child: _MiniMetric(
                    icon: CupertinoIcons.flame_fill,
                    label: 'Longest Streak',
                    value: '19 days',
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: BlurCard(
                  child: _MiniMetric(
                    icon: CupertinoIcons.person_2_fill,
                    label: 'Active Members',
                    value: '24',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const BlurCard(
            child: _MiniMetric(
              icon: CupertinoIcons.rosette,
              label: 'Top Contributor (Today)',
              value: 'Amin - 4,120',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last 7 Days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('527,430', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Up 12.4% from previous week',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.7),
          ),
          alignment: Alignment.center,
          child: Text(
            'Sparkline placeholder',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

