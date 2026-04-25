import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/features/profile/privacy_policy_page.dart';
import 'package:selawathub/features/profile/terms_of_service_page.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.isSignUp = false, this.initialEmail});
  final bool isSignUp;
  final String? initialEmail;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _isSignUp = widget.isSignUp;
  bool _loading = false;
  bool _agreedToTerms = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  final _termsRecognizer = TapGestureRecognizer();
  final _privacyRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsRecognizer.onTap = _openTerms;
    _privacyRecognizer.onTap = _openPrivacy;
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passwordFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _passwordFocus.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
    );
  }

  void _openPrivacy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
    );
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final l = AppL10n.of(context);

    if (email.isEmpty || password.isEmpty) {
      showAppSnackBar(context, l.loginErrorFillFields);
      return;
    }
    if (_isSignUp && name.isEmpty) {
      showAppSnackBar(context, l.loginErrorNameRequired);
      return;
    }
    if (password.length < 6) {
      showAppSnackBar(context, l.loginErrorPasswordLength);
      return;
    }
    if (_isSignUp && password != _confirmPasswordCtrl.text.trim()) {
      showAppSnackBar(context, l.loginErrorPasswordMismatch);
      return;
    }
    if (_isSignUp && !_agreedToTerms) {
      showAppSnackBar(context, l.loginErrorAgreeTerms);
      return;
    }

    setState(() => _loading = true);

    AuthService.expectingManualAuth = true;
    try {
      if (_isSignUp) {
        final res = await AuthService.signUp(
          email: email,
          password: password,
          name: name,
        );
        if (!mounted) return;
        // Supabase returns a "fake" user with an empty identities list when
        // signing up with an email that is already registered (this is a
        // deliberate anti-enumeration measure when email confirmations are
        // enabled). Detect that and surface a real error instead of the
        // misleading "Check your email" message.
        final user = res.user;
        final identities = user?.identities;
        final alreadyRegistered =
            user != null && (identities == null || identities.isEmpty);
        if (alreadyRegistered) {
          showAppSnackBar(
            context,
            l.loginErrorEmailExists,
            backgroundColor: C.error,
          );
          AuthService.expectingManualAuth = false;
          setState(() => _loading = false);
          return;
        }
        if (user != null && user.emailConfirmedAt == null) {
          showAppSnackBar(context, l.loginCheckEmailVerify);
          AuthService.expectingManualAuth = false;
          setState(() => _loading = false);
          return;
        }
      } else {
        await AuthService.signIn(email: email, password: password);
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      AuthService.expectingManualAuth = false;
      showAppSnackBar(context, e.message);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      AuthService.expectingManualAuth = false;
      showAppSnackBar(context, l.loginGenericError);
      setState(() => _loading = false);
    }
  }

  void _showForgotPassword() {
    final resetEmailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    showAppFormSheet(
      context: context,
      builder: (ctx) => _ForgotPasswordSheet(controller: resetEmailCtrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: S.page),
          children: [
            const SizedBox(height: S.s16),

            // Back
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dark ? C.dark3 : C.light3,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.back,
                    size: 18,
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: S.s40),

            // Heading
            FadeIn(
              child: Text(
                _isSignUp ? l.loginCreateTitle : l.loginTitle,
                style: tt.headlineLarge,
              ),
            ),
            const SizedBox(height: S.s8),
            FadeIn(
              delay: const Duration(milliseconds: 80),
              child: Text(
                _isSignUp ? l.loginSubtitleSignUp : l.loginSubtitleSignIn,
                style: tt.bodyMedium,
              ),
            ),

            const SizedBox(height: S.s40),

            // Name field (sign up only)
            if (_isSignUp) ...[
              FadeIn(
                delay: const Duration(milliseconds: 120),
                child: _Field(
                  controller: _nameCtrl,
                  label: l.loginNameLabel,
                  hint: l.loginNameHint,
                  icon: CupertinoIcons.person,
                  dark: dark,
                ),
              ),
              const SizedBox(height: S.s16),
            ],

            // Email
            FadeIn(
              delay: Duration(milliseconds: _isSignUp ? 160 : 120),
              child: _Field(
                controller: _emailCtrl,
                label: l.loginEmailLabel,
                hint: l.loginEmailHint,
                icon: CupertinoIcons.mail,
                dark: dark,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: S.s16),

            // Password
            FadeIn(
              delay: Duration(milliseconds: _isSignUp ? 200 : 160),
              child: _Field(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                label: l.loginPasswordLabel,
                hint: l.loginPasswordHint,
                icon: CupertinoIcons.lock,
                dark: dark,
                obscure: true,
              ),
            ),

            // Confirm password (sign up only)
            if (_isSignUp) ...[
              const SizedBox(height: S.s16),
              FadeIn(
                delay: const Duration(milliseconds: 240),
                child: _Field(
                  controller: _confirmPasswordCtrl,
                  label: l.loginConfirmPasswordLabel,
                  hint: l.loginConfirmPasswordHint,
                  icon: CupertinoIcons.lock,
                  dark: dark,
                  obscure: true,
                ),
              ),
            ],

            if (!_isSignUp) ...[
              const SizedBox(height: S.s12),
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showForgotPassword,
                    child: Text(
                      l.loginForgotPassword,
                      style: tt.bodySmall?.copyWith(
                        color: dark ? C.primarySoft : C.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: S.s32),

            // Terms & Privacy agreement (sign-up only)
            if (_isSignUp) ...[
              FadeIn(
                delay: const Duration(milliseconds: 260),
                child: _AgreementRow(
                  dark: dark,
                  tt: tt,
                  l: l,
                  checked: _agreedToTerms,
                  onChanged: (v) => setState(() => _agreedToTerms = v),
                  termsRecognizer: _termsRecognizer,
                  privacyRecognizer: _privacyRecognizer,
                ),
              ),
              const SizedBox(height: S.s20),
            ],

            // Submit
            FadeIn(
              delay: Duration(milliseconds: _isSignUp ? 280 : 240),
              offset: const Offset(0, 20),
              child: Builder(builder: (_) {
                final disabled =
                    _loading || (_isSignUp && !_agreedToTerms);
                return BounceTap(
                  onTap: disabled ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: disabled
                          ? (dark
                              ? C.primarySoft.withValues(alpha: 0.5)
                              : C.primary.withValues(alpha: 0.5))
                          : (dark ? C.primarySoft : C.primary),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: C.white,
                              ),
                            )
                          : Text(
                              _isSignUp ? l.loginSubmitSignUp : l.loginSubmitSignIn,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: C.white,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: S.s24),

            // Toggle
            FadeIn(
              delay: Duration(milliseconds: _isSignUp ? 340 : 300),
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                  child: RichText(
                    text: TextSpan(
                      style: tt.bodySmall,
                      children: [
                        TextSpan(
                          text: _isSignUp ? l.loginHaveAccount : l.loginNoAccount,
                        ),
                        TextSpan(
                          text: _isSignUp ? l.loginSignInLink : l.loginSignUpLink,
                          style: TextStyle(
                            color: dark ? C.primarySoft : C.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.dark,
    this.obscure = false,
    this.keyboardType,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool dark;
  final bool obscure;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: S.s8),
          child: Text(widget.label, style: tt.titleSmall),
        ),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          style: tt.bodyMedium?.copyWith(
            color: widget.dark ? C.onDark1 : C.onLight1,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(widget.icon, size: 18, color: widget.dark ? C.onDark3 : C.onLight3),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.obscure
                ? GestureDetector(
                    onTap: () => setState(() => _hidden = !_hidden),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        _hidden ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        size: 18,
                        color: widget.dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}

// ── Terms & Privacy agreement row (sign-up only) ──

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.dark,
    required this.tt,
    required this.l,
    required this.checked,
    required this.onChanged,
    required this.termsRecognizer,
    required this.privacyRecognizer,
  });

  final bool dark;
  final TextTheme tt;
  final AppL10n l;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer privacyRecognizer;

  @override
  Widget build(BuildContext context) {
    final accent = dark ? C.primarySoft : C.primary;
    final muted = dark ? C.onDark2 : C.onLight2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox — tap target also toggles when label area tapped via parent
        GestureDetector(
          onTap: () => onChanged(!checked),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: checked ? accent : Colors.transparent,
              border: Border.all(
                color: checked
                    ? accent
                    : (dark ? C.darkDivider : C.lightDivider),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: checked
                ? Icon(CupertinoIcons.check_mark,
                    size: 16, color: C.white)
                : null,
          ),
        ),
        const SizedBox(width: S.s12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!checked),
            behavior: HitTestBehavior.opaque,
            child: RichText(
              text: TextSpan(
                style: tt.bodySmall?.copyWith(color: muted, height: 1.45),
                children: [
                  TextSpan(text: l.loginAgreementPrefix),
                  TextSpan(
                    text: l.loginAgreementTerms,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: accent,
                    ),
                    recognizer: termsRecognizer,
                  ),
                  TextSpan(text: l.loginAgreementAnd),
                  TextSpan(
                    text: l.loginAgreementPrivacy,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: accent,
                    ),
                    recognizer: privacyRecognizer,
                  ),
                  TextSpan(text: l.loginAgreementSuffix),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Forgot Password Bottom Sheet ──

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet({required this.controller});
  final TextEditingController controller;

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  bool _sending = false;

  Future<void> _send() async {
    final email = widget.controller.text.trim();
    final l = AppL10n.of(context);
    if (email.isEmpty) {
      showAppSnackBar(context, l.forgotPasswordEmailRequired,
          backgroundColor: C.error);
      return;
    }

    setState(() => _sending = true);
    try {
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      Navigator.pop(context);
      showAppSnackBar(context, l.forgotPasswordSent);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showAppSnackBar(context, e.message, backgroundColor: C.error);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      showAppSnackBar(context, l.loginGenericError,
          backgroundColor: C.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        S.page,
        S.s8,
        S.page,
        MediaQuery.of(context).viewInsets.bottom + S.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.forgotPasswordTitle,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: S.s8),
          Text(
            l.forgotPasswordBody,
            style: tt.bodySmall?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
          const SizedBox(height: S.s24),
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            style: tt.bodyMedium?.copyWith(
              color: dark ? C.onDark1 : C.onLight1,
            ),
            decoration: InputDecoration(
              hintText: l.forgotPasswordEmailHint,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(CupertinoIcons.mail,
                    size: 18, color: dark ? C.onDark3 : C.onLight3),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
          const SizedBox(height: S.s24),
          SizedBox(
            width: double.infinity,
            child: BounceTap(
              onTap: _sending ? null : _send,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _sending
                      ? (dark
                          ? C.primarySoft.withValues(alpha: 0.5)
                          : C.primary.withValues(alpha: 0.5))
                      : (dark ? C.primarySoft : C.primary),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: C.white,
                          ),
                        )
                      : Text(
                          l.forgotPasswordSubmit,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: C.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}