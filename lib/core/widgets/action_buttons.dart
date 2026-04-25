import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

/// Standardized Cancel/Save (or any two-action) button row.
class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel,
    this.confirmLabel,
    this.saving = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String? cancelLabel;
  final String? confirmLabel;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);
    final cancelText = cancelLabel ?? l.commonCancel;
    final confirmText = confirmLabel ?? l.commonSave;
    return Row(
      children: [
        Expanded(
          child: BounceTap(
            onTap: saving ? null : onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: S.s12),
              decoration: BoxDecoration(
                color: dark ? C.dark4 : C.light3,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  cancelText,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: S.s12),
        Expanded(
          child: BounceTap(
            onTap: saving ? null : onConfirm,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: S.s12),
              decoration: BoxDecoration(
                color: dark ? C.primarySoft : C.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: C.white,
                        ),
                      )
                    : Text(
                        confirmText,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: C.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
