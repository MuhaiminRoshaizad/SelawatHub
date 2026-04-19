import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _lastUpdated = '19 April 2026';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: S.page,
          right: S.page,
          top: S.s24,
          bottom: S.s24 + MediaQuery.of(context).padding.bottom,
        ),
        child: FadeIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: tt.headlineSmall?.copyWith(
                  color: dark ? C.onDark1 : C.onLight1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: S.s4),
              Text(
                'Last updated: $_lastUpdated',
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(height: S.s24),
              _section(
                tt,
                dark,
                'Introduction',
                'SelawatHub ("we", "our", or "us") is a mobile application designed '
                    'to help Muslims count selawat and zikir, track their devotional '
                    'progress, and participate in group dhikr activities. We are '
                    'committed to protecting your privacy and handling your personal '
                    'data transparently. This Privacy Policy explains what information '
                    'we collect, how we use it, and your rights regarding your data.',
              ),
              _section(
                tt,
                dark,
                '1. Information We Collect',
                'Account Information\n'
                    'When you create an account, we collect your email address and a '
                    'display name you choose. Your password is securely hashed and '
                    'stored by our authentication provider (Supabase) — we never have '
                    'access to your plaintext password.\n\n'
                    'Profile Information\n'
                    'You may optionally provide a bio and upload a profile picture. '
                    'Profile pictures are stored in secure cloud storage and are '
                    'visible to members of groups you join.\n\n'
                    'Usage Data\n'
                    'We collect data about your selawat and zikir counts, including '
                    'the type of dhikr, count totals, and timestamps. This data is '
                    'used to generate your personal statistics, streaks, and progress '
                    'tracking.\n\n'
                    'Group Data\n'
                    'If you create or join a group, we store group membership '
                    'information, your role within the group, and your dhikr '
                    'contributions that are shared with other group members.\n\n'
                    'Guest Usage\n'
                    'If you use SelawatHub as a guest without creating an account, '
                    'your dhikr counts and preferences are stored locally on your '
                    'device only. No personal data is transmitted to our servers in '
                    'guest mode.',
              ),
              _section(
                tt,
                dark,
                '2. How We Use Your Information',
                'We use the information we collect to:\n\n'
                    '• Provide core app functionality — counting selawat/zikir, '
                    'tracking progress, and displaying statistics\n'
                    '• Enable group features — allowing you to join groups, share '
                    'progress, and view group leaderboards\n'
                    '• Authenticate your identity and secure your account\n'
                    '• Send password reset emails when requested\n'
                    '• Store and display your profile information to other group members\n'
                    '• Calculate streaks, daily goals, and weekly/monthly/yearly statistics\n'
                    '• Improve the app experience based on usage patterns',
              ),
              _section(
                tt,
                dark,
                '3. Data Storage & Security',
                'Your data is stored on Supabase, a secure cloud platform with '
                    'industry-standard security practices including:\n\n'
                    '• Encrypted data transmission (HTTPS/TLS)\n'
                    '• Row Level Security (RLS) policies ensuring users can only '
                    'access their own data\n'
                    '• Secure password hashing using bcrypt\n'
                    '• Profile pictures stored in access-controlled cloud storage\n\n'
                    'Local data (guest mode counts, app preferences such as theme '
                    'selection, haptic feedback settings, and daily goals) is stored '
                    'on your device using SharedPreferences and is not transmitted to '
                    'our servers.',
              ),
              _section(
                tt,
                dark,
                '4. Data Sharing',
                'We do not sell, trade, or rent your personal information to third '
                    'parties. Your data may be shared in the following limited '
                    'circumstances:\n\n'
                    '• Group Members — Your display name, profile picture, and dhikr '
                    'counts are visible to members of groups you join\n'
                    '• Service Providers — We use Supabase for authentication, '
                    'database, and storage services. Supabase processes data on our '
                    'behalf under strict data processing agreements\n'
                    '• Legal Requirements — We may disclose information if required '
                    'by law or to protect our rights and safety',
              ),
              _section(
                tt,
                dark,
                '5. Your Rights',
                'You have the right to:\n\n'
                    '• Access — View your personal data through the app\'s profile '
                    'and statistics pages\n'
                    '• Update — Edit your display name, bio, and profile picture at '
                    'any time\n'
                    '• Delete — Request deletion of your account and associated data '
                    'by contacting us\n'
                    '• Password — Change your password or request a password reset '
                    'at any time\n'
                    '• Data Portability — Your statistics and activity data are '
                    'accessible through the app',
              ),
              _section(
                tt,
                dark,
                '6. Children\'s Privacy',
                'SelawatHub does not knowingly collect personal information from '
                    'children under the age of 13. If you believe a child has '
                    'provided us with personal data, please contact us so we can '
                    'take appropriate action.',
              ),
              _section(
                tt,
                dark,
                '7. Changes to This Policy',
                'We may update this Privacy Policy from time to time. Changes will '
                    'be reflected in the "Last updated" date at the top of this page. '
                    'Continued use of the app after changes constitutes acceptance of '
                    'the updated policy.',
              ),
              _section(
                tt,
                dark,
                '8. Contact Us',
                'If you have questions about this Privacy Policy or wish to exercise '
                    'your data rights, please contact us at:\n\n'
                    'Email: selawathub@gmail.com',
              ),
              const SizedBox(height: S.s48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(TextTheme tt, bool dark, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: S.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: dark ? C.onDark1 : C.onLight1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: S.s8),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
