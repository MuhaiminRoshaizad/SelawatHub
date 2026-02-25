import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/widgets/app_background.dart';
import 'package:selawathub/core/widgets/blur_card.dart';
import 'package:selawathub/features/settings/presentation/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.settings),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 18),
          const BlurCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Icon(CupertinoIcons.person_fill, size: 24),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amin Muhaimin'),
                      SizedBox(height: 2),
                      Text('Group Leader'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const BlurCard(
            child: _ProfileRow(
              title: 'Current Group',
              subtitle: 'SelawatHub Community',
            ),
          ),
          const SizedBox(height: 12),
          const BlurCard(
            child: _ProfileRow(
              title: 'Join Code',
              subtitle: 'SLWT-7861',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
