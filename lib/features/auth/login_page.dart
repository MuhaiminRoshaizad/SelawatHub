import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/app/app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.isSignUp = false});
  final bool isSignUp;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _isSignUp = widget.isSignUp;

  void _submit() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppShell()),
      (_) => false,
    );
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
                label: 'Password',
                hint: 'Enter your password',
                icon: CupertinoIcons.lock,
                dark: dark,
                obscure: true,
              ),
            ),

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
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: dark ? C.primarySoft : C.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.dark,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool dark;
  final bool obscure;
  final TextInputType? keyboardType;

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
          obscureText: obscure,
          keyboardType: keyboardType,
          style: tt.bodyMedium?.copyWith(
            color: dark ? C.onDark1 : C.onLight1,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, size: 18, color: dark ? C.onDark3 : C.onLight3),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}
