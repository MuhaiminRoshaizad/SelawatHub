import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pw = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    final l = AppL10n.of(context);

    if (pw.isEmpty) {
      showAppSnackBar(context, l.resetPasswordEmpty,
          backgroundColor: C.error);
      return;
    }
    if (pw.length < 6) {
      showAppSnackBar(context, l.resetPasswordTooShort,
          backgroundColor: C.error);
      return;
    }
    if (pw != confirm) {
      showAppSnackBar(context, l.resetPasswordMismatch,
          backgroundColor: C.error);
      return;
    }

    setState(() => _saving = true);
    try {
      await AuthService.updatePassword(pw);
      if (!mounted) return;
      showAppSnackBar(context, l.resetPasswordSuccess);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, e.message, backgroundColor: C.error);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, l.resetPasswordFailed,
          backgroundColor: C.error);
    }
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
            const SizedBox(height: S.s64),

            FadeIn(
              child: Icon(
                CupertinoIcons.lock_shield,
                size: 56,
                color: dark ? C.primarySoft : C.primary,
              ),
            ),
            const SizedBox(height: S.s24),

            FadeIn(
              delay: const Duration(milliseconds: 80),
              child: Text(
                l.resetPasswordTitle,
                style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: S.s8),
            FadeIn(
              delay: const Duration(milliseconds: 120),
              child: Text(
                l.resetPasswordSubtitle,
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: S.s40),

            // New Password
            FadeIn(
              delay: const Duration(milliseconds: 160),
              child: _PasswordField(
                controller: _passwordCtrl,
                label: l.resetPasswordNewLabel,
                hint: l.resetPasswordNewHint,
                hidden: _hidePassword,
                onToggle: () =>
                    setState(() => _hidePassword = !_hidePassword),
                dark: dark,
              ),
            ),
            const SizedBox(height: S.s16),

            // Confirm Password
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: _PasswordField(
                controller: _confirmCtrl,
                label: l.resetPasswordConfirmLabel,
                hint: l.resetPasswordConfirmHint,
                hidden: _hideConfirm,
                onToggle: () =>
                    setState(() => _hideConfirm = !_hideConfirm),
                dark: dark,
              ),
            ),

            const SizedBox(height: S.s32),

            // Submit
            FadeIn(
              delay: const Duration(milliseconds: 240),
              offset: const Offset(0, 20),
              child: BounceTap(
                onTap: _saving ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _saving
                        ? (dark
                            ? C.primarySoft.withValues(alpha: 0.5)
                            : C.primary.withValues(alpha: 0.5))
                        : (dark ? C.primarySoft : C.primary),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: C.white,
                            ),
                          )
                        : Text(
                            l.resetPasswordSubmit,
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
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.hidden,
    required this.onToggle,
    required this.dark,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool hidden;
  final VoidCallback onToggle;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: S.s8),
          child: Text(label, style: tt.titleSmall),
        ),
        TextField(
          controller: controller,
          obscureText: hidden,
          style: tt.bodyMedium?.copyWith(
            color: dark ? C.onDark1 : C.onLight1,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(CupertinoIcons.lock,
                  size: 18, color: dark ? C.onDark3 : C.onLight3),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  hidden ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 18,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}
