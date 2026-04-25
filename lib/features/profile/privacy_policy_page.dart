import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _lastUpdated = '25 April 2026';

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
                'SelawatHub ("we", "our", or "us") is a mobile application '
                    'developed by an individual developer based in Malaysia, '
                    'designed to help Muslims count selawat and zikir, track '
                    'their devotional progress, and participate in group dhikr '
                    'activities. We are committed to protecting your privacy '
                    'and handling your personal data transparently.\n\n'
                    'This Privacy Policy explains what information we collect, '
                    'how we use it, and your rights regarding your data. It is '
                    'prepared in line with the Malaysian Personal Data '
                    'Protection Act 2010, as amended by the Personal Data '
                    'Protection (Amendment) Act 2024.',
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
                    'tracking. Counts may originate either from tapping the in-app '
                    'counter or from manual entries you make (for dhikr completed '
                    'using a physical tasbih).\n\n'
                    'User-Generated Content\n'
                    'If you create custom selawat or zikir entries, the names you '
                    'provide are stored against your account. These names are visible '
                    'only to you and are never shown to other users or group members.\n\n'
                    'Group Data\n'
                    'If you create or join a group, we store group membership '
                    'information, your role within the group, and your dhikr '
                    'contributions that are shared with other group members.\n\n'
                    'Guest Usage\n'
                    'If you use SelawatHub as a guest without creating an account, '
                    'your dhikr counts and preferences are stored locally on your '
                    'device only. No personal data is transmitted to our servers in '
                    'guest mode. Note that custom dhikr creation is not available in '
                    'guest mode.\n\n'
                    'Sensitive Personal Data\n'
                    'We do not collect sensitive personal data as defined under the '
                    'Personal Data Protection Act 2010 (such as physical or mental '
                    'health, political opinions, religious beliefs beyond what is '
                    'inherent in your use of the app, or biometric data).',
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
                '4. Data Sharing & International Transfers',
                'We do not sell, trade, or rent your personal information to third '
                    'parties. Your data may be shared in the following limited '
                    'circumstances:\n\n'
                    '• Group Members — Your display name, profile picture, and dhikr '
                    'counts are visible to members of groups you join\n'
                    '• Service Providers — We use Supabase for authentication, '
                    'database, and storage services. Supabase processes data on our '
                    'behalf under strict data processing agreements\n'
                    '• Legal Requirements — We may disclose information if required '
                    'by law or to protect our rights and safety\n\n'
                    'International Transfers\n'
                    'Supabase may store and process data in jurisdictions outside '
                    'Malaysia. Such transfers are made only to jurisdictions providing '
                    'a level of data protection equivalent to that required by the '
                    'Malaysian Personal Data Protection Act 2010 (as amended), and '
                    'are subject to Supabase\'s contractual security and privacy '
                    'commitments.',
              ),
              _section(
                tt,
                dark,
                '5. Your Rights',
                'Under the Personal Data Protection Act 2010 (as amended by the '
                    'Personal Data Protection (Amendment) Act 2024), you have the '
                    'right to:\n\n'
                    '• Access — View your personal data through the app\'s profile '
                    'and statistics pages, or request a copy by contacting us\n'
                    '• Correction — Edit your display name, bio, profile picture, '
                    'and dhikr counts at any time. You may also request correction '
                    'of any other inaccurate data by contacting us\n'
                    '• Deletion — Request deletion of your account and associated '
                    'data by contacting us\n'
                    '• Withdrawal of Consent — Withdraw your consent to data '
                    'processing at any time by deleting your account; note that '
                    'doing so will end your ability to use account-bound features\n'
                    '• Data Portability — Request a copy of your personal data '
                    '(account, counts, custom dhikr, group membership) in a '
                    'structured, commonly used electronic format, and request that '
                    'we transmit it directly to another data controller where '
                    'technically feasible\n'
                    '• Password — Change your password or request a password reset '
                    'at any time\n'
                    '• Lodge a Complaint — You may lodge a complaint with the '
                    'Personal Data Protection Department of Malaysia (Jabatan '
                    'Perlindungan Data Peribadi, JPDP) if you believe your rights '
                    'have been infringed',
              ),
              _section(
                tt,
                dark,
                '6. Data Breach Notification',
                'In the event of a personal data breach that is likely to result in '
                    'significant harm to you, we will notify both the Personal Data '
                    'Protection Commissioner and affected users without undue delay '
                    'and, where feasible, within seventy-two (72) hours of becoming '
                    'aware of the breach, in accordance with the Personal Data '
                    'Protection (Amendment) Act 2024.',
              ),
              _section(
                tt,
                dark,
                '7. Data Retention',
                'We retain your personal data for as long as your account is active. '
                    'If you delete your account, your personal data is removed within '
                    'a reasonable period, except where we are required to retain '
                    'certain records to comply with applicable law or to resolve '
                    'disputes. Local guest-mode data persists on your device until '
                    'you uninstall the app or clear app storage.',
              ),
              _section(
                tt,
                dark,
                '8. Children\'s Privacy',
                'SelawatHub does not knowingly collect personal information from '
                    'children under the age of 13. If you believe a child has '
                    'provided us with personal data, please contact us so we can '
                    'take appropriate action.',
              ),
              _section(
                tt,
                dark,
                '9. Changes to This Policy',
                'We may update this Privacy Policy from time to time. Changes will '
                    'be reflected in the "Last updated" date at the top of this page. '
                    'Continued use of the app after changes constitutes acceptance of '
                    'the updated policy.',
              ),
              _section(
                tt,
                dark,
                '10. Contact Us',
                'If you have questions about this Privacy Policy or wish to exercise '
                    'your data rights under the Personal Data Protection Act 2010 (as '
                    'amended), please contact us at:\n\n'
                    'Email: aminmuhaimin192@gmail.com\n\n'
                    'SelawatHub is operated by an individual developer in Malaysia. '
                    'No Data Protection Officer has been appointed because the '
                    'processing volume falls below the thresholds set out in the '
                    'Personal Data Protection (Amendment) Act 2024. The developer '
                    'acts as the data controller for the purposes of this Policy.',
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
