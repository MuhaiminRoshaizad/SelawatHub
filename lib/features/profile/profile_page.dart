import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selawathub/app/app.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/services/locale_controller.dart';
import 'package:selawathub/core/services/profile_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_refresh_indicator.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/confirmation_dialog.dart';
import 'package:selawathub/core/widgets/language_picker_sheet.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:selawathub/features/profile/about_page.dart';
import 'package:selawathub/features/profile/edit_profile_page.dart';
import 'package:selawathub/features/profile/help_faq_page.dart';
import 'package:selawathub/features/profile/widgets/profile_header.dart';
import 'package:selawathub/features/profile/widgets/profile_rows.dart';
import 'package:selawathub/features/profile/widgets/profile_stats_row.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';
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
  bool _streakActive = false;
  int _daysActive = 0;
  late final bool _isGuest = widget.isGuest;


  static final _numFmt = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadProfile();
  }

  /// Synchronously populate state from cached profile so the first frame
  /// shows real data on app restart / tab switch — no skeleton flicker.
  /// The network refresh in [_loadProfile] still runs to pick up any
  /// server-side changes.
  void _hydrateFromCache() {
    if (_isGuest) {
      _loading = false;
      return;
    }
    final uid = SupabaseService.userId;
    final cached = SettingsService.getCachedProfile(uid);
    if (cached == null) return;
    _name = cached['name'] as String? ?? '';
    _bio = cached['bio'] as String? ?? '';
    _avatarUrl = cached['avatar_url'] as String?;
    _email =
        (cached['email'] as String?)?.isNotEmpty == true
            ? cached['email'] as String
            : (SupabaseService.currentUser?.email ?? '');
    _totalDhikr = (cached['total_dhikr'] as int?) ?? 0;
    _streak = (cached['streak'] as int?) ?? 0;
    _streakActive = (cached['streak_active'] as bool?) ?? false;
    _daysActive = (cached['days_active'] as int?) ?? 0;
    _loading = false;
  }

  Future<void> _loadProfile() async {
    if (_isGuest) {
      if (mounted && _loading) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await ProfileService.getProfile();
      final stats = await ProfileService.getProfileStats();
      if (!mounted) return;
      final name = profile?['name'] as String? ?? '';
      final bio = profile?['bio'] as String? ?? '';
      final avatarUrl = profile?['avatar_url'] as String?;
      final email = SupabaseService.currentUser?.email ?? '';
      final totalDhikr = (stats['total_dhikr'] as num?)?.toInt() ?? 0;
      final streak = (stats['streak'] as num?)?.toInt() ?? 0;
      final streakActive = (stats['streak_active'] as bool?) ?? false;
      final daysActive = (stats['days_active'] as num?)?.toInt() ?? 0;
      setState(() {
        _name = name;
        _bio = bio;
        _avatarUrl = avatarUrl;
        _email = email;
        _totalDhikr = totalDhikr;
        _streak = streak;
        _streakActive = streakActive;
        _daysActive = daysActive;
        _loading = false;
      });
      // Persist so next app launch renders instantly.
      final uid = SupabaseService.userId;
      if (uid != null) {
        SettingsService.setCachedProfile(
          userId: uid,
          name: name,
          bio: bio,
          avatarUrl: avatarUrl,
          email: email,
          totalDhikr: totalDhikr,
          streak: streak,
          streakActive: streakActive,
          daysActive: daysActive,
        );
      }
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

  String _memberSince(BuildContext context) {
    final created = SupabaseService.currentUser?.createdAt;
    if (created == null) return '';
    final dt = DateTime.tryParse(created);
    if (dt == null) return created;
    final localeStr = Localizations.localeOf(context).toString();
    return DateFormat.yMMMM(localeStr).format(dt);
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

  void _showAvatarFullscreen(String url) {
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(S.s24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final themeCtrl = ThemeController.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    final accent = dark ? C.primarySoft : C.primary;
    final l = AppL10n.of(context);

    return Skeletonizer(
      enabled: _loading,
      child: AppRefreshIndicator(
        topOffset: topPad,
        onRefresh: () async {
          await _loadProfile();
        },
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
        // ── Clean minimal header (avatar + edit badge) ──
        FadeIn(
          child: ProfileHeader(
            dark: dark,
            topPad: topPad,
            isGuest: _isGuest,
            avatarUrl: _avatarUrl,
            initials: _initials,
            accent: accent,
            onEditTap: _openEditProfile,
            onAvatarTap: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? () => _showAvatarFullscreen(_avatarUrl!)
                : null,
          ),
        ),

        // ── Name + bio ──
        FadeIn(
          delay: const Duration(milliseconds: 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Column(
              children: [
                const SizedBox(height: S.s16),
                Text(
                  _isGuest ? l.profileGuestBadge : (_name.isEmpty ? (SupabaseService.currentUser?.userMetadata?['name'] as String? ?? l.profileSetYourName) : _name),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!_isGuest) ...[
                  const SizedBox(height: S.s4),
                  Text(
                    _bio.isEmpty ? l.profileBioPlaceholder : _bio,
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
              accent: accent,
              totalDhikr: _numFmt.format(_totalDhikr),
              streak: _numFmt.format(_streak),
              daysActive: _numFmt.format(_daysActive),
              streakActive: _streakActive,
            ),
          ),
        ),

        const SizedBox(height: S.s24),

        // ── Account Info section (authenticated only) ──
        if (!_isGuest) ...[
        _sectionHeader(l.profileSectionAccountInfo, 200, dark),
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
                    label: l.profileEmailLabel,
                    value: _email,
                  ),
                  _divider(dark),
                  InfoRow(
                    icon: CupertinoIcons.calendar,
                    label: l.profileMemberSinceLabel,
                    value: _memberSince(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],

        if (!_isGuest) ...[
          const SizedBox(height: S.s24),

          // ── Group section (will be wired separately) ──
        ],

        const SizedBox(height: S.s24),

        // ── Settings section ──
        _sectionHeader(l.profileSectionSettings, 360, dark),
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
                    builder: (context, mode, child) => DarkModeRow(
                      value: dark,
                      onChanged: (v) => themeCtrl.value =
                          v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                  _divider(dark),
                  MenuRow(
                    icon: CupertinoIcons.globe,
                    label: l.languageCurrent,
                    trailing: _languageLabel(context),
                    onTap: () => showLanguagePickerSheet(context),
                  ),
                  if (!_isGuest) ...[
                    _divider(dark),
                    MenuRow(
                      icon: CupertinoIcons.lock_fill,
                      label: l.profileChangePassword,
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
        _sectionHeader(l.profileSectionSupport, 440, dark),
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
                    label: l.profileHelpAndFaq,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqPage())),
                  ),
                  _divider(dark),
                  MenuRow(
                    icon: CupertinoIcons.info_circle,
                    label: l.profileAboutApp,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
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
                            l.profileSignIn,
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
                    onTap: () {
                      showConfirmDialog(
                        context: context,
                        title: l.profileSignOutConfirmTitle,
                        message: l.profileSignOutConfirmBody,
                        actionLabel: l.profileSignOutAction,
                        errorMessage: l.profileSignOutFailed,
                        onConfirm: () async {
                          await AuthService.signOut();
                          // Let showConfirmDialog auto-pop the dialog first,
                          // then navigate on the next frame via the root
                          // navigator. Navigating synchronously here races
                          // with the helper's post-await Navigator.pop and
                          // ends up popping our new WelcomePage.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SelawatHubApp.navKey.currentState?.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const WelcomePage(),
                              ),
                              (_) => false,
                            );
                          });
                        },
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
                            l.profileSignOut,
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
              l.profileVersion('1.0.0'),
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

  /// Trailing text for the Language MenuRow — reflects current LocaleController
  /// state. "System" for follow-system, otherwise the native name.
  String _languageLabel(BuildContext context) {
    final mode = LocaleController.of(context).value;
    final l = AppL10n.of(context);
    switch (mode) {
      case LocaleMode.english:
        return l.languageEnglish;
      case LocaleMode.malay:
        return l.languageMalay;
      default:
        return l.languageSystem;
    }
  }

  void _showChangePassword(BuildContext context) {
    final l = AppL10n.of(context);
    showAppFormSheet(
      context: context,
      builder: (ctx) => _ChangePasswordSheet(
        onSaved: () {
          Navigator.pop(ctx);
          showAppSnackBar(context, l.changePasswordSuccess);
        },
      ),
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

// ── Change password sheet with visibility toggles ──
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({required this.onSaved});
  final VoidCallback onSaved;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;
  bool _sendingReset = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final l = AppL10n.of(context);
    final currentPw = _currentCtrl.text;
    final newPw = _newCtrl.text;
    final confirmPw = _confirmCtrl.text;
    if (currentPw.isEmpty) {
      showAppSnackBar(context, l.changePasswordCurrentRequired,
          backgroundColor: C.error);
      return;
    }
    if (newPw.length < 6) {
      showAppSnackBar(context, l.resetPasswordTooShort,
          backgroundColor: C.error);
      return;
    }
    if (newPw != confirmPw) {
      showAppSnackBar(context, l.resetPasswordMismatch,
          backgroundColor: C.error);
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService.verifyPassword(currentPw);
      await AuthService.updatePassword(newPw);
      widget.onSaved();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final msg = e.message.contains('Invalid login')
          ? l.changePasswordCurrentIncorrect
          : e.message;
      showAppSnackBar(context, msg, backgroundColor: C.error);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, l.changePasswordFailed,
          backgroundColor: C.error);
    }
  }

  Future<void> _sendResetEmail() async {
    final l = AppL10n.of(context);
    final email = AuthService.currentEmail;
    if (email == null) {
      showAppSnackBar(context, l.changePasswordEmailMissing,
          backgroundColor: C.error);
      return;
    }
    setState(() => _sendingReset = true);
    try {
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      Navigator.pop(context);
      showAppSnackBar(context, l.changePasswordResetSent(email));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sendingReset = false);
      showAppSnackBar(context, l.changePasswordResetFailed,
          backgroundColor: C.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppL10n.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(S.page, S.s8, S.page, MediaQuery.of(context).viewInsets.bottom + S.page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.changePasswordTitle, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: S.s24),
          TextField(
            controller: _currentCtrl,
            obscureText: !_showCurrent,
            decoration: InputDecoration(
              labelText: l.changePasswordCurrentLabel,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _showCurrent = !_showCurrent),
                child: Icon(
                  _showCurrent ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 18,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),
          ),
          const SizedBox(height: S.s8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _sendingReset ? null : _sendResetEmail,
              child: Text(
                _sendingReset ? l.changePasswordSending : l.changePasswordForgotLink,
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.primarySoft : C.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: S.s16),
          TextField(
            controller: _newCtrl,
            obscureText: !_showNew,
            decoration: InputDecoration(
              labelText: l.changePasswordNewLabel,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _showNew = !_showNew),
                child: Icon(
                  _showNew ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 18,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),
          ),
          const SizedBox(height: S.s16),
          TextField(
            controller: _confirmCtrl,
            obscureText: !_showConfirm,
            decoration: InputDecoration(
              labelText: l.changePasswordConfirmLabel,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _showConfirm = !_showConfirm),
                child: Icon(
                  _showConfirm ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 18,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),
          ),
          const SizedBox(height: S.s24),
          ActionButtons(
            saving: _saving,
            onCancel: () => Navigator.pop(context),
            onConfirm: _changePassword,
          ),
        ],
      ),
    );
  }
}
