import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/app_colors.dart';
import 'package:selawathub/core/widgets/app_background.dart';
import 'package:selawathub/core/widgets/blur_card.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('Tasbih Counter', style: textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Tap and sync your selawat into your group daily total.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          const BlurCard(child: _CounterHero()),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Today',
                  value: '1,240',
                  accent: AppColors.ocean,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  label: 'Group',
                  value: '85,121',
                  accent: AppColors.mint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterHero extends StatelessWidget {
  const _CounterHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Today Count',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '1,240',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 42,
              ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 210,
          height: 210,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.white,
              elevation: 0,
            ),
            onPressed: () {},
            child: const Icon(Icons.add, size: 54),
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reset with confirmation'),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return BlurCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

