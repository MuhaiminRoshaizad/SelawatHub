import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const _lastUpdated = '19 April 2026';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(title: const Text('Terms of Service')),
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
                'Terms of Service',
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
                'Welcome to SelawatHub. By downloading, installing, or using this '
                    'application, you agree to be bound by these Terms of Service '
                    '("Terms"). If you do not agree to these Terms, please do not '
                    'use the app.',
              ),
              _section(
                tt,
                dark,
                '1. Description of Service',
                'SelawatHub is a mobile application that provides:\n\n'
                    '• A digital tasbih (counter) for selawat and zikir with '
                    'customisable dhikr types and target counts\n'
                    '• Personal statistics tracking including daily, weekly, monthly, '
                    'and yearly progress with streaks and configurable daily goals\n'
                    '• Group features allowing users to create or join groups, share '
                    'dhikr progress, and view collective statistics\n'
                    '• A curated collection of daily hadith\n'
                    '• Profile management with customisable display name, bio, and '
                    'profile picture\n'
                    '• Guest mode for using basic features without an account',
              ),
              _section(
                tt,
                dark,
                '2. User Accounts',
                'Account Creation\n'
                    'You may create an account using your email address and a '
                    'password of at least 6 characters. You must provide a display '
                    'name during registration. You are responsible for maintaining '
                    'the confidentiality of your login credentials.\n\n'
                    'Guest Mode\n'
                    'You may use SelawatHub without creating an account. Guest users '
                    'can access the counter and view statistics stored locally on '
                    'their device. Guest data is not synced to the cloud and may be '
                    'lost if the app is uninstalled.\n\n'
                    'Account Security\n'
                    'You are responsible for all activity that occurs under your '
                    'account. If you suspect unauthorised access, change your '
                    'password immediately through the app\'s profile settings or '
                    'use the password reset feature.',
              ),
              _section(
                tt,
                dark,
                '3. Acceptable Use',
                'You agree to use SelawatHub only for its intended purpose of '
                    'facilitating Islamic devotional practices. You must not:\n\n'
                    '• Use the app for any unlawful or prohibited purpose\n'
                    '• Upload inappropriate, offensive, or non-Islamic content as '
                    'your profile picture or bio\n'
                    '• Attempt to interfere with the app\'s functionality, security, '
                    'or infrastructure\n'
                    '• Create multiple accounts for the purpose of manipulating '
                    'group statistics or leaderboards\n'
                    '• Share group invite codes publicly without the group '
                    'administrator\'s consent\n'
                    '• Harass, intimidate, or harm other users through group '
                    'interactions\n'
                    '• Attempt to access other users\' data or accounts',
              ),
              _section(
                tt,
                dark,
                '4. Groups',
                'Group Creation & Management\n'
                    'Any registered user may create a group. The group creator '
                    'becomes the group admin with the ability to manage members, '
                    'update group settings, set daily goals, and remove members.\n\n'
                    'Membership\n'
                    'Users may join a group using an invite code. Each user may '
                    'belong to one group at a time. Your dhikr counts contributed '
                    'while in a group are visible to all group members.\n\n'
                    'Leaving or Removal\n'
                    'You may leave a group at any time. Group admins may remove '
                    'members at their discretion. If a group admin leaves, '
                    'administrative privileges are transferred to another member.',
              ),
              _section(
                tt,
                dark,
                '5. User Content',
                'You retain ownership of content you provide (display name, bio, '
                    'profile picture). By uploading content, you grant SelawatHub a '
                    'non-exclusive licence to display that content within the app '
                    'for the purpose of providing the service (e.g., showing your '
                    'profile picture to group members).\n\n'
                    'We reserve the right to remove content that violates these '
                    'Terms or is deemed inappropriate.',
              ),
              _section(
                tt,
                dark,
                '6. Intellectual Property',
                'The SelawatHub app, including its design, code, graphics, and '
                    'content (excluding user-generated content), is the intellectual '
                    'property of SelawatHub and is protected by applicable copyright '
                    'and intellectual property laws. You may not copy, modify, '
                    'distribute, or reverse-engineer any part of the app.',
              ),
              _section(
                tt,
                dark,
                '7. Disclaimer of Warranties',
                'SelawatHub is provided "as is" and "as available" without '
                    'warranties of any kind, whether express or implied. We do not '
                    'guarantee that:\n\n'
                    '• The app will be available at all times without interruption\n'
                    '• The app will be free from errors or defects\n'
                    '• Data will never be lost (please note guest data is stored '
                    'locally and may be lost upon app uninstallation)\n'
                    '• The statistical calculations will be perfectly accurate',
              ),
              _section(
                tt,
                dark,
                '8. Limitation of Liability',
                'To the maximum extent permitted by law, SelawatHub and its '
                    'developers shall not be liable for any indirect, incidental, '
                    'special, or consequential damages arising from your use of or '
                    'inability to use the app. This includes but is not limited to '
                    'loss of data, loss of streaks, or interruption of service.',
              ),
              _section(
                tt,
                dark,
                '9. Termination',
                'We reserve the right to suspend or terminate your account if you '
                    'violate these Terms. You may delete your account at any time by '
                    'contacting us. Upon termination, your right to use the app '
                    'ceases and your data may be deleted in accordance with our '
                    'Privacy Policy.',
              ),
              _section(
                tt,
                dark,
                '10. Changes to Terms',
                'We may update these Terms from time to time. Changes will be '
                    'reflected in the "Last updated" date at the top. Your continued '
                    'use of the app after modifications constitutes acceptance of '
                    'the revised Terms.',
              ),
              _section(
                tt,
                dark,
                '11. Governing Law',
                'These Terms shall be governed by and construed in accordance with '
                    'the laws of Malaysia. Any disputes arising from these Terms '
                    'shall be subject to the exclusive jurisdiction of the courts '
                    'of Malaysia.',
              ),
              _section(
                tt,
                dark,
                '12. Contact Us',
                'If you have questions about these Terms of Service, please contact '
                    'us at:\n\n'
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
