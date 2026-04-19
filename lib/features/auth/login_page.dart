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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.isSignUp = false});
  final bool isSignUp;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _isSignUp = widget.isSignUp;
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showAppSnackBar(context, 'Please fill in all fields');
      return;
    }
    if (_isSignUp && name.isEmpty) {
      showAppSnackBar(context, 'Please enter your name');
      return;
    }
    if (password.length < 6) {
      showAppSnackBar(context, 'Password must be at least 6 characters');
      return;
    }
    if (_isSignUp && password != _confirmPasswordCtrl.text.trim()) {
      showAppSnackBar(context, 'Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isSignUp) {
        final res = await AuthService.signUp(
          email: email,
          password: password,
          name: name,
        );
        if (!mounted) return;
        if (res.user != null && res.user!.emailConfirmedAt == null) {
          showAppSnackBar(context, 'Check your email to verify your account');
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
      showAppSnackBar(context, e.message);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Something went wrong. Please try again.');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

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
                _isSignUp ? 'Create Account' : 'Welcome back',
                style: tt.headlineLarge,
              ),
            ),
            const SizedBox(height: S.s8),
            FadeIn(
              delay: const Duration(milliseconds: 80),
              child: Text(
                _isSignUp
                    ? 'Start your selawat journey'
                    : 'Continue your selawat journey',
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
                  label: 'Full Name',
                  hint: 'Enter your name',
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
                label: 'Email',
                hint: 'Enter your email',
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
                label: 'Password',
                hint: 'Enter your password',
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
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
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
                  child: Text(
                    'Forgot password?',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.primarySoft : C.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: S.s32),

            // Submit
            FadeIn(
              delay: Duration(milliseconds: _isSignUp ? 280 : 240),
              offset: const Offset(0, 20),
              child: BounceTap(
                onTap: _loading ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _loading
                        ? (dark ? C.primarySoft.withValues(alpha: 0.5) : C.primary.withValues(alpha: 0.5))
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
                            _isSignUp ? 'Create Account' : 'Sign In',
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
                          text: _isSignUp
                              ? 'Already have an account? '
                              : 'Don\'t have an account? ',
                        ),
                        TextSpan(
                          text: _isSignUp ? 'Sign In' : 'Sign Up',
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
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool dark;
  final bool obscure;
  final TextInputType? keyboardType;

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
