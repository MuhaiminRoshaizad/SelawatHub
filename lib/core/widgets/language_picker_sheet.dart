import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/locale_controller.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

/// Bottom sheet that lets the user switch the app language.
///
/// Shows three options — System default, English, Bahasa Melayu — using
/// the same row pattern as the rest of the app's pickers (radio dot +
/// label). Selecting an option persists it via [LocaleController.set] and
/// closes the sheet; the [MaterialApp] above will rebuild with the new
/// locale automatically.
Future<void> showLanguagePickerSheet(BuildContext context) {
  return showAppFormSheet<void>(
    context: context,
    isScrollControlled: false,
    builder: (ctx) {
      return const _LanguagePickerSheet();
    },
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);
    final current = LocaleController.of(context).value;

    final options = <_LangOption>[
      _LangOption(LocaleMode.system, l.languageSystem, _systemHint(context)),
      _LangOption(LocaleMode.english, l.languageEnglish, 'English'),
      _LangOption(LocaleMode.malay, l.languageMalay, 'Bahasa Melayu'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(S.page, S.s8, S.page, S.page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.globe,
                  size: 22, color: dark ? C.primarySoft : C.primary),
              const SizedBox(width: S.s12),
              Text(l.languagePickerTitle,
                  style:
                      tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: S.s4),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              l.languagePickerSubtitle,
              style: tt.bodySmall
                  ?.copyWith(color: dark ? C.onDark2 : C.onLight2),
            ),
          ),
          const SizedBox(height: S.s16),
          for (final opt in options)
            BounceTap(
              onTap: () {
                LocaleController.set(context, opt.mode);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: S.s12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: current == opt.mode
                              ? (dark ? C.primarySoft : C.primary)
                              : (dark ? C.onDark3 : C.onLight3),
                          width: 2,
                        ),
                        color: current == opt.mode
                            ? (dark ? C.primarySoft : C.primary)
                            : Colors.transparent,
                      ),
                      child: current == opt.mode
                          ? const Icon(Icons.check,
                              size: 16, color: C.white)
                          : null,
                    ),
                    const SizedBox(width: S.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(opt.label, style: tt.bodyLarge),
                          if (opt.hint.isNotEmpty)
                            Text(
                              opt.hint,
                              style: tt.bodySmall?.copyWith(
                                color: dark ? C.onDark3 : C.onLight3,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Hint shown next to "System default" — explains which actual language
  /// will be used right now based on the device locale.
  String _systemHint(BuildContext context) {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    return device.languageCode == 'ms' ? 'Bahasa Melayu' : 'English';
  }
}

class _LangOption {
  const _LangOption(this.mode, this.label, this.hint);
  final int mode;
  final String label;
  final String hint;
}
