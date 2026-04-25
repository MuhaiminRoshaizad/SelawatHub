import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────
//  Error view with retry
// ─────────────────────────────────────────────────────────

class HadithErrorView extends StatelessWidget {
  const HadithErrorView({
    super.key,
    required this.dark,
    required this.tt,
    required this.onRetry,
  });
  final bool dark;
  final TextTheme tt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(S.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.wifi_slash,
                size: 48,
                color: dark ? C.onDark3 : C.onLight3,
              ),
              const SizedBox(height: S.s16),
              Text(
                l.hadithErrorTitle,
                style: tt.titleMedium?.copyWith(
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
              const SizedBox(height: S.s8),
              Text(
                l.hadithErrorBody,
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                ),
              ),
              const SizedBox(height: S.s24),
              BounceTap(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.s24, vertical: S.s12),
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l.commonRetry,
                    style: const TextStyle(
                      color: C.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
