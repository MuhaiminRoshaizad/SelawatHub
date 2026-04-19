import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/services/profile_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:selawathub/features/profile/about_page.dart';
import 'package:selawathub/features/profile/edit_profile_page.dart';
import 'package:selawathub/features/profile/help_faq_page.dart';
import 'package:selawathub/features/profile/widgets/profile_banner.dart';
import 'package:selawathub/features/profile/widgets/profile_rows.dart';
import 'package:selawathub/features/profile/widgets/profile_stats_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _bio = '';
  String _email = '';
  String? _avatarUrl;
  bool _loading = true;
  int _totalDhikr = 0;
  int _streak = 0;
  int _daysActive = 0;
  late final bool _isGuest = widget.isGuest;
  String _language = 'English';

  static final _numFmt = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_isGuest) {
      setState(() => _loading = false);
      return;
    }
    try {
      final profile = await ProfileService.getProfile();
      final stats = await ProfileService.getProfileStats();
      if (!mounted) return;
      setState(() {
        _name = profile?['name'] as String? ?? '';
        _bio = profile?['bio'] as String? ?? '';
        _avatarUrl = profile?['avatar_url'] as String?;
        _email = SupabaseService.currentUser?.email ?? '';
        _totalDhikr = (stats['total_dhikr'] as num?)?.toInt() ?? 0;
        _streak = (stats['streak'] as num?)?.toInt() ?? 0;
        _daysActive = (stats['days_active'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get _memberSince {
    final created = SupabaseService.currentUser?.createdAt;
    if (created == null) return '';
    final dt = DateTime.tryParse(created);
    if (dt == null) return created;
    return DateFormat.yMMMM().format(dt);
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          name: _name,
          bio: _bio,
          avatarUrl: _avatarUrl,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _name = result['name'] ?? _name;
        _bio = result['bio'] ?? _bio;
        if (result.containsKey('avatar_url')) {
          _avatarUrl = result['avatar_url'];
        }
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

    return Skeletonizer(
      enabled: _loading,
      child: RefreshIndicator(
        color: accent,
        onRefresh: () async {
          await _loadProfile();
        },
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
        // ── Banner + Avatar hero ──
        FadeIn(
          child: ProfileBanner(
            dark: dark,
            tt: tt,
            topPad: topPad,
            isGuest: _isGuest,
            avatarUrl: _avatarUrl,
            initials: _initials,
            accent: accent,
            onEditTap: _openEditProfile,
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
                  _isGuest ? 'Guest' : (_name.isEmpty ? 'Placeholder Name' : _name),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!_isGuest) ...[
                  const SizedBox(height: S.s4),
                  Text(
                    _bio.isEmpty ? 'A short bio goes here' : _bio,
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
            child: ProfileStatsRow(
              dark: dark,
              accent: accent,
              totalDhikr: _numFmt.format(_totalDhikr),
              streak: _numFmt.format(_streak),
              daysActive: _numFmt.format(_daysActive),
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
                  InfoRow(
                    icon: CupertinoIcons.mail,
                    label: 'Email',
                    value: _email,
                    dark: dark,
                  ),
                  _divider(dark),
                  InfoRow(
                    icon: CupertinoIcons.calendar,
                    label: 'Member Since',
                    value: _memberSince,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),

        if (!_isGuest) ...[
          const SizedBox(height: S.s24),

          // ── Group section (will be wired separately) ──
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
                    builder: (context, mode, child) => ToggleRow(
                      icon: CupertinoIcons.moon_fill,
                      label: 'Dark Mode',
                      value: dark,
                      dark: dark,
                      onChanged: (v) => themeCtrl.value =
                          v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                  _divider(dark),
                  ToggleRow(
                    icon: CupertinoIcons.bell_fill,
                    label: 'Notifications',
                    value: true,
                    dark: dark,
                    onChanged: (_) {},
                  ),
                  _divider(dark),
                  MenuRow(
                    icon: CupertinoIcons.globe,
                    label: 'Language',
                    trailing: _language,
                    dark: dark,
                    onTap: () => _showLanguagePicker(context),
                  ),
                  if (!_isGuest) ...[
                    _divider(dark),
                    MenuRow(
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
                  MenuRow(
                    icon: CupertinoIcons.question_circle,
                    label: 'Help & FAQ',
                    dark: dark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqPage())),
                  ),
                  _divider(dark),
                  MenuRow(
                    icon: CupertinoIcons.info_circle,
                    label: 'About SelawatHub',
                    dark: dark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                  ),
                  _divider(dark),
                  MenuRow(
                    icon: CupertinoIcons.share,
                    label: 'Share App',
                    dark: dark,
                    onTap: () => showAppSnackBar(context, 'Share link copied to clipboard!'),
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
                    onTap: () async {
                      await AuthService.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const WelcomePage()),
                        (_) => false,
                      );
                    },
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
    ),
    ),
    );
  }

  // ── Helpers ──

  void _showLanguagePicker(BuildContext context) {
    showAppFormSheet(
      context: context,
      isScrollControlled: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final dark = Theme.of(ctx).brightness == Brightness.dark;
            final tt = Theme.of(ctx).textTheme;
            return Padding(
              padding: const EdgeInsets.fromLTRB(S.page, S.s8, S.page, S.page),
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
                        showAppSnackBar(context, 'Language changed to $lang');
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
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showAppFormSheet(
      context: context,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(S.page, S.s8, S.page, MediaQuery.of(ctx).viewInsets.bottom + S.page),
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
                  showAppSnackBar(context, 'Password changed successfully');
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
