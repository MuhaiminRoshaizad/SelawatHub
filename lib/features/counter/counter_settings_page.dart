import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/tick_sound_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/bead_circle.dart';
import 'package:selawathub/core/widgets/frosted_app_bar.dart';
import 'package:selawathub/core/widgets/section_header.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';
import 'package:selawathub/features/counter/widgets/digital_counter.dart';
import 'package:selawathub/features/counter/widgets/minimal_counter.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

const colorThemes = [
  ('Emerald', C.primarySoft),
  ('Gold', C.goldSoft),
  ('Ocean', Color(0xFF5B8FB9)),
  ('Rose', Color(0xFFC07070)),
  ('Lavender', Color(0xFF9B8EC4)),
  ('Ivory', Color(0xFFC4B998)),
];

class CounterSettingsResult {
  const CounterSettingsResult({
    required this.hapticEnabled,
    required this.hapticIntensity,
    required this.soundEnabled,
    required this.soundStyle,
    required this.counterStyle,
    required this.customTargets,
    required this.colorThemeIndex,
  });
  final bool hapticEnabled;
  final int hapticIntensity;
  final bool soundEnabled;
  final int soundStyle;
  final int counterStyle;
  final Map<String, int> customTargets;
  final int colorThemeIndex;
}

class CounterSettingsPage extends StatefulWidget {
  const CounterSettingsPage({
    super.key,
    required this.hapticEnabled,
    required this.hapticIntensity,
    required this.soundEnabled,
    required this.soundStyle,
    required this.counterStyle,
    required this.customTargets,
    required this.colorThemeIndex,
  });

  final bool hapticEnabled;
  final int hapticIntensity;
  final bool soundEnabled;
  final int soundStyle;
  final int counterStyle;
  final Map<String, int> customTargets;
  final int colorThemeIndex;

  @override
  State<CounterSettingsPage> createState() => _CounterSettingsPageState();
}

class _CounterSettingsPageState extends State<CounterSettingsPage> {
  late bool _hapticEnabled;
  late int _hapticIntensity;
  late bool _soundEnabled;
  late int _soundStyle;
  late int _counterStyle;
  late Map<String, int> _customTargets;
  late int _colorThemeIndex;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = widget.hapticEnabled;
    _hapticIntensity = widget.hapticIntensity;
    _soundEnabled = widget.soundEnabled;
    _soundStyle = widget.soundStyle;
    _counterStyle = widget.counterStyle;
    _customTargets = Map.of(widget.customTargets);
    _colorThemeIndex = widget.colorThemeIndex;
  }

  void _pop() {
    Navigator.pop<CounterSettingsResult>(
      context,
      CounterSettingsResult(
        hapticEnabled: _hapticEnabled,
        hapticIntensity: _hapticIntensity,
        soundEnabled: _soundEnabled,
        soundStyle: _soundStyle,
        counterStyle: _counterStyle,
        customTargets: _customTargets,
        colorThemeIndex: _colorThemeIndex,
      ),
    );
  }

  int _targetFor(Dhikr d) => _customTargets[d.id] ?? d.defaultTarget;

  void _editTarget(Dhikr d) {
    final controller = TextEditingController(text: '${_targetFor(d)}');
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppL10n.of(context);

    showAppFormSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            S.page, S.s8, S.page,
            MediaQuery.of(ctx).viewInsets.bottom + S.page,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
              const SizedBox(height: S.s16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l.settingsTargetCountLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: S.s20),
              ActionButtons(
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  final val = int.tryParse(controller.text);
                  if (val != null && val > 0) {
                    setState(() => _customTargets[d.id] = val);
                    Navigator.pop(ctx);
                    showAppSnackBar(context, l.settingsTargetSetToast(d.name, val));
                  } else {
                    showAppSnackBar(ctx, l.settingsTargetInvalid, backgroundColor: C.error);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    return PopScope(
      canPop: false,
      // Intercept both the app-bar back button path (via _pop) and the
      // Android system back gesture, which would otherwise pop without
      // returning the updated settings — causing the counter page to
      // discard changes and feel "stuck" on the old color/style.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 56),
              const SizedBox(height: S.s16),

              // ── General ──
              if (!kIsWeb) ...[
                SectionHeader(text: l.settingsSectionGeneral, style: SectionHeaderStyle.title),
                _MenuContainer(
                  dark: dark,
                  children: [
                    _SwitchRow(
                      icon: CupertinoIcons.bolt_fill,
                      label: l.settingsHapticFeedback,
                      value: _hapticEnabled,
                      onChanged: (v) => setState(() => _hapticEnabled = v),
                    ),
                    if (_hapticEnabled) ...[
                      Divider(
                        height: 1,
                        color: dark ? C.darkDivider : C.lightDivider,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: S.s16, vertical: S.s12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              l.settingsIntensity,
                              style: TextStyle(
                                color: dark ? C.onDark1 : C.onLight1,
                              ),
                            ),
                            const Spacer(),
                            _SegmentedControl<int>(
                              dark: dark,
                              value: _hapticIntensity,
                              items: {
                                0: l.settingsIntensityLight,
                                1: l.settingsIntensityMedium,
                                2: l.settingsIntensityHeavy,
                              },
                              onChanged: (v) =>
                                  setState(() => _hapticIntensity = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.s20),
                  child: Padding(
                    padding: const EdgeInsets.only(top: S.s6),
                    child: Text(
                      l.settingsHapticHelp,
                      style: TextStyle(
                        fontSize: 11,
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: S.s24),

                // ── Tick Sound ──
                _MenuContainer(
                  dark: dark,
                  children: [
                    _SwitchRow(
                      icon: CupertinoIcons.speaker_2_fill,
                      label: l.settingsTickSound,
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                    ),
                    if (_soundEnabled) ...[
                      Divider(
                        height: 1,
                        color: dark ? C.darkDivider : C.lightDivider,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: S.s16, vertical: S.s12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0;
                                i < TickSoundService.styleNames.length;
                                i++)
                              _TickStyleRow(
                                dark: dark,
                                label: TickSoundService.styleNames[i],
                                selected: _soundStyle == i,
                                onTap: () {
                                  setState(() => _soundStyle = i);
                                  TickSoundService.play(i);
                                },
                                onPreview: () => TickSoundService.play(i),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.s20),
                  child: Padding(
                    padding: const EdgeInsets.only(top: S.s6),
                    child: Text(
                      l.settingsTickSoundHelp,
                      style: TextStyle(
                        fontSize: 11,
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: S.s24),
              ],

              // ── Appearance ──
              SectionHeader(text: l.settingsSectionAppearance, style: SectionHeaderStyle.title),
              _MenuContainer(
                dark: dark,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.s16, vertical: S.s12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          l.settingsCounterStyle,
                          style: TextStyle(
                            color: dark ? C.onDark1 : C.onLight1,
                          ),
                        ),
                        const Spacer(),
                        _SegmentedControl<int>(
                          dark: dark,
                          value: _counterStyle,
                          items: {
                            0: l.settingsCounterStyleBead,
                            1: l.settingsCounterStyleDigital,
                            2: l.settingsCounterStyleMinimal,
                          },
                          onChanged: (v) => setState(() => _counterStyle = v),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: dark ? C.darkDivider : C.lightDivider,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: S.s16),
                    child: Center(
                      child: switch (_counterStyle) {
                        0 => BeadCircle(
                          total: 33,
                          filled: 12,
                          size: 120,
                          accentColor: colorThemes[_colorThemeIndex].$2,
                        ),
                        1 => DigitalCounter(
                          total: 33,
                          filled: 12,
                          size: 120,
                          accentColor: colorThemes[_colorThemeIndex].$2,
                        ),
                        _ => MinimalCounter(
                          total: 33,
                          filled: 12,
                          size: 120,
                          accentColor: colorThemes[_colorThemeIndex].$2,
                        ),
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: S.s16),

              // ── Color Theme ──
              _MenuContainer(
                dark: dark,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: S.s16, vertical: S.s12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.settingsColorTheme,
                          style: TextStyle(
                            color: dark ? C.onDark1 : C.onLight1,
                          ),
                        ),
                        const SizedBox(height: S.s12),
                        Row(
                          children: [
                            for (int i = 0; i < colorThemes.length; i++) ...[
                              if (i > 0) const SizedBox(width: S.s12),
                              GestureDetector(
                                onTap: () => setState(() => _colorThemeIndex = i),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colorThemes[i].$2,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _colorThemeIndex == i
                                      ? const Icon(
                                          CupertinoIcons.checkmark,
                                          size: 14,
                                          color: C.white,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: S.s24),

              // ── Targets ──
              SectionHeader(
                text: l.settingsTargetsTitle,
                subtitle: l.settingsTargetsSub,
                style: SectionHeaderStyle.title,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(S.page, S.s12, S.page, S.s8),
                child: Text(
                  l.manualCategorySelawat,
                  style: tt.labelLarge?.copyWith(
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
              _MenuContainer(
                dark: dark,
                children: _buildDhikrRows(Dhikr.selawatList, dark),
              ),

              const SizedBox(height: S.s16),

              Padding(
                padding: const EdgeInsets.fromLTRB(S.page, S.s4, S.page, S.s8),
                child: Text(
                  l.manualCategoryZikir,
                  style: tt.labelLarge?.copyWith(
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
              _MenuContainer(
                dark: dark,
                children: _buildDhikrRows(Dhikr.zikirList, dark),
              ),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom + S.s32,
              ),
            ],
          ),

          // ── Frosted app bar ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: FrostedAppBar(
              title: l.settingsTitle,
              onBack: _pop,
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildDhikrRows(List<Dhikr> list, bool dark) {
    final widgets = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      if (i > 0) {
        widgets.add(
          Divider(height: 1, color: dark ? C.darkDivider : C.lightDivider),
        );
      }
      final d = list[i];
      widgets.add(
        GestureDetector(
          onTap: () => _editTarget(d),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: S.s16, vertical: S.s12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    d.name,
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
                  ),
                ),
                Text(
                  '${_targetFor(d)}',
                  style: TextStyle(color: dark ? C.onDark2 : C.onLight2),
                ),
                const SizedBox(width: S.s8),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

// ── Helpers ──

class _TickStyleRow extends StatelessWidget {
  const _TickStyleRow({
    required this.dark,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onPreview,
  });
  final bool dark;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final accent = dark ? C.primarySoft : C.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: S.s8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : (dark ? C.onDark3 : C.onLight3),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: S.s12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
              ),
            ),
            GestureDetector(
              onTap: onPreview,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: S.s12, vertical: S.s4,
                ),
                child: Icon(
                  CupertinoIcons.play_circle,
                  size: 22,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuContainer extends StatelessWidget {
  const _MenuContainer({required this.dark, required this.children});
  final bool dark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.page),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon = CupertinoIcons.bolt_fill,
  });
  final String label;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
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
            child: Center(child: Icon(icon, size: 16, color: accent)),
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

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.dark,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final bool dark;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? C.dark4 : C.light3,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(S.s2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.entries.map((e) {
          final selected = e.key == value;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: S.s12, vertical: S.s6,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? (dark ? C.primarySoft : C.primary)
                    : C.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? C.white
                      : (dark ? C.onDark2 : C.onLight2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
