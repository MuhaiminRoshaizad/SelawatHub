import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:selawathub/features/profile/about_page.dart';
import 'package:selawathub/features/profile/edit_profile_page.dart';
import 'package:selawathub/features/profile/help_faq_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Amin Muhaimin';
  String _bio = 'Striving for consistency ✨';
  String _email = 'amin@example.com';
  late final bool _isGuest = widget.isGuest;
  String _language = 'English';

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          name: _name,
          bio: _bio,
          email: _email,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _name = result['name'] ?? _name;
        _bio = result['bio'] ?? _bio;
        _email = result['email'] ?? _email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final themeCtrl = ThemeController.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    final accent = dark ? C.primarySoft : C.primary;

    // Banner height includes safe area + space for content + avatar overlap
    const bannerBody = 160.0;
    const avatarSize = 96.0;
    const avatarOverlap = avatarSize / 2;
    final bannerH = topPad + bannerBody;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Banner + Avatar hero ──
        FadeIn(
          child: SizedBox(
            height: bannerH + avatarOverlap + 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient banner with curved bottom
                ClipPath(
                  clipper: _CurvedBannerClipper(),
                  child: Container(
                    height: bannerH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark
                            ? [
                                C.primaryMuted,
                                const Color(0xFF1A3D28),
                              ]
                            : [
                                C.primary,
                                C.primarySoft,
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Geometric pattern overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _IslamicPatternPainter(
                              color: C.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        // "Profile" title
                        Positioned(
                          top: topPad + 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Profile',
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: C.white,
                              ),
                            ),
                          ),
                        ),
                        // Edit pen in top-right
                        Positioned(
                          top: topPad + 8,
                          right: S.s16,
                          child: BounceTap(
                            onTap: _openEditProfile,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: C.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.pencil,
                                size: 18,
                                color: C.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar overlapping the banner
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: dark ? C.dark1 : C.light1,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? C.dark1 : C.light1,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: C.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent.withValues(alpha: 0.15),
                              C.goldGlow,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isGuest
                              ? const Text(
                                  '👤',
                                  style: TextStyle(fontSize: 30),
                                )
                              : Text(
                                  _initials,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Name + bio ──
        FadeIn(
          delay: const Duration(milliseconds: 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Column(
              children: [
                const SizedBox(height: S.s4),
                Text(
                  _isGuest ? 'Guest' : _name,
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!_isGuest) ...[
                  const SizedBox(height: S.s4),
                  Text(
                    _bio,
                    style: tt.bodyMedium?.copyWith(
                      color: dark ? C.onDark2 : C.onLight2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: S.s24),

        // ── Stats row ──
        FadeIn(
          delay: const Duration(milliseconds: 140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: S.s20),
              decoration: BoxDecoration(
                color: dark ? C.dark3 : C.light2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dark ? C.darkDivider : C.lightDivider,
                  width: 0.5,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _StatItem(
                      value: '28,450',
                      label: 'Total Dhikr',
                      icon: CupertinoIcons.heart_fill,
                      iconColor: accent,
                    ),
                    VerticalDivider(
                        width: 1,
                        color: dark ? C.darkDivider : C.lightDivider),
                    _StatItem(
                      value: '19',
                      label: 'Day Streak',
                      icon: CupertinoIcons.flame_fill,
                      iconColor: C.gold,
                    ),
                    VerticalDivider(
                        width: 1,
                        color: dark ? C.darkDivider : C.lightDivider),
                    _StatItem(
                      value: '45',
                      label: 'Days Active',
                      icon: CupertinoIcons.calendar,
                      iconColor: accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s24),

        // ── Account Info section ──
        _sectionHeader('Account Info', 200, dark),
        FadeIn(
          delay: const Duration(milliseconds: 240),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? C.dark3 : C.light2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dark ? C.darkDivider : C.lightDivider,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: CupertinoIcons.mail,
                    label: 'Email',
                    value: _email,
                    dark: dark,
                  ),
                  _divider(dark),
                  _InfoRow(
                    icon: CupertinoIcons.calendar,
                    label: 'Member Since',
                    value: 'March 2026',
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),

        if (!_isGuest) ...[
          const SizedBox(height: S.s24),

          // ── Group section ──
          _sectionHeader('Group', 280, dark),
          FadeIn(
            delay: const Duration(milliseconds: 320),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: dark ? C.darkDivider : C.lightDivider,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: CupertinoIcons.person_3_fill,
                      label: 'Group',
                      value: 'SelawatHub Family',
                      dark: dark,
                    ),
                    _divider(dark),
                    _InfoRow(
                      icon: CupertinoIcons.number,
                      label: 'Code',
                      value: 'SLWT-7861',
                      dark: dark,
                    ),
                    _divider(dark),
                    _InfoRow(
                      icon: CupertinoIcons.star_fill,
                      label: 'Role',
                      value: 'Leader',
                      dark: dark,
                      valueColor: C.gold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: S.s24),

        // ── Settings section ──
        _sectionHeader('Settings', 360, dark),
        FadeIn(
          delay: const Duration(milliseconds: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? C.dark3 : C.light2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dark ? C.darkDivider : C.lightDivider,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeCtrl,
                    builder: (context, mode, child) => _ToggleRow(
                      icon: CupertinoIcons.moon_fill,
                      label: 'Dark Mode',
                      value: dark,
                      dark: dark,
                      onChanged: (v) => themeCtrl.value =
                          v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                  _divider(dark),
                  _ToggleRow(
                    icon: CupertinoIcons.bell_fill,
                    label: 'Notifications',
                    value: true,
                    dark: dark,
                    onChanged: (_) {},
                  ),
                  _divider(dark),
                  _MenuRow(
                    icon: CupertinoIcons.globe,
                    label: 'Language',
                    trailing: _language,
                    dark: dark,
                    onTap: () => _showLanguagePicker(context),
                  ),
                  if (!_isGuest) ...[
                    _divider(dark),
                    _MenuRow(
                      icon: CupertinoIcons.lock_fill,
                      label: 'Change Password',
                      dark: dark,
                      onTap: () => _showChangePassword(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s24),

        // ── About & Help section ──
        _sectionHeader('Support', 440, dark),
        FadeIn(
          delay: const Duration(milliseconds: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? C.dark3 : C.light2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dark ? C.darkDivider : C.lightDivider,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  _MenuRow(
                    icon: CupertinoIcons.question_circle,
                    label: 'Help & FAQ',
                    dark: dark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqPage())),
                  ),
                  _divider(dark),
                  _MenuRow(
                    icon: CupertinoIcons.info_circle,
                    label: 'About SelawatHub',
                    dark: dark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                  ),
                  _divider(dark),
                  _MenuRow(
                    icon: CupertinoIcons.share,
                    label: 'Share App',
                    dark: dark,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share link copied to clipboard!')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s24),

        // ── Sign Out / Sign In ──
        FadeIn(
          delay: const Duration(milliseconds: 540),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: _isGuest
                ? BounceTap(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WelcomePage())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: S.s16),
                      decoration: BoxDecoration(
                        color: dark
                            ? C.primary.withValues(alpha: 0.08)
                            : C.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: C.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.square_arrow_left,
                            size: 16,
                            color: dark ? C.primarySoft : C.primary,
                          ),
                          const SizedBox(width: S.s8),
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: dark ? C.primarySoft : C.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : BounceTap(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: S.s16),
                      decoration: BoxDecoration(
                        color: dark
                            ? C.error.withValues(alpha: 0.08)
                            : C.error.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: C.error.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.square_arrow_right,
                            size: 16,
                            color: C.error,
                          ),
                          const SizedBox(width: S.s8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: C.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: S.s16),

        // Version
        FadeIn(
          delay: const Duration(milliseconds: 580),
          child: Center(
            child: Text(
              'SelawatHub v1.0.0',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark3 : C.onLight3,
                fontSize: 11,
              ),
            ),
          ),
        ),

        SizedBox(
            height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
      ],
    );
  }

  // ── Helpers ──

  void _showLanguagePicker(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? C.dark2 : C.light1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final tt = Theme.of(ctx).textTheme;
            return Padding(
              padding: const EdgeInsets.all(S.page),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Language', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: S.s24),
                  for (final lang in ['English', 'Bahasa Melayu'])
                    BounceTap(
                      onTap: () {
                        setState(() => _language = lang);
                        setSheetState(() {});
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Language changed to $lang')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: S.s16),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _language == lang
                                      ? (dark ? C.primarySoft : C.primary)
                                      : (dark ? C.onDark3 : C.onLight3),
                                  width: 2,
                                ),
                                color: _language == lang
                                    ? (dark ? C.primarySoft : C.primary)
                                    : Colors.transparent,
                              ),
                              child: _language == lang
                                  ? const Icon(Icons.check, size: 16, color: C.white)
                                  : null,
                            ),
                            const SizedBox(width: S.s16),
                            Text(lang, style: tt.bodyLarge),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: MediaQuery.of(ctx).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePassword(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? C.dark2 : C.light1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(S.page, S.page, S.page, MediaQuery.of(ctx).viewInsets.bottom + S.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: S.s24),
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              const SizedBox(height: S.s16),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
              const SizedBox(height: S.s16),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
              const SizedBox(height: S.s24),
              ActionButtons(
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully')),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  static Widget _sectionHeader(String text, int delay, bool dark) {
    return FadeIn(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(S.page + 4, 0, S.page, S.s12),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: dark ? C.onDark3 : C.onLight3,
          ),
        ),
      ),
    );
  }

  static Widget _divider(bool dark) => Divider(
        height: 1,
        indent: 52,
        color: dark ? C.darkDivider : C.lightDivider,
      );
}

// ─────────────────────────────────────────────────────────
//  Curved banner clipper
// ─────────────────────────────────────────────────────────

class _CurvedBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width / 2, size.height + 20,
        size.width, size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────
//  Islamic geometric pattern painter (subtle overlay)
// ─────────────────────────────────────────────────────────

class _IslamicPatternPainter extends CustomPainter {
  _IslamicPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 40.0;
    const radius = 16.0;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        // Draw small 8-pointed star shapes
        _drawStar(canvas, Offset(x, y), radius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const points = 8;
    final innerR = r * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final rad = i.isEven ? r : innerR;
      final x = center.dx + rad * cos(angle);
      final y = center.dy + rad * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────
//  Stat item with icon
// ─────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: S.s6),
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: S.s2),
          Text(label, style: tt.bodySmall),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Info row (label + value)
// ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.dark,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool dark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: accent),
            ),
          ),
          const SizedBox(width: S.s12),
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
          ),
          Text(
            value,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? (dark ? C.onDark1 : C.onLight1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Menu row (tappable with chevron)
// ─────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.dark,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool dark;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    return BounceTap(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: accent),
              ),
            ),
            const SizedBox(width: S.s12),
            Expanded(
              child: Text(label, style: tt.titleSmall),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(width: S.s4),
            ],
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: dark ? C.onDark3 : C.onLight3,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Toggle row (switch)
// ─────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.dark,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final bool dark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: accent),
            ),
          ),
          const SizedBox(width: S.s12),
          Expanded(child: Text(label, style: tt.titleSmall)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accent.withValues(alpha: 0.4),
            activeThumbColor: accent,
          ),
        ],
      ),
    );
  }
}
