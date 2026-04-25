import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

typedef _Faq = ({String question, String answer});
typedef _Section = ({String title, IconData icon, List<_Faq> faqs});

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  List<_Section> _buildSections(AppL10n l) {
    return [
      (
        title: l.faqSectionTasbih,
        icon: Icons.touch_app,
        faqs: [
          (question: l.faqQ_tasbih_count_q, answer: l.faqQ_tasbih_count_a),
          (question: l.faqQ_tasbih_change_q, answer: l.faqQ_tasbih_change_a),
          (question: l.faqQ_tasbih_target_q, answer: l.faqQ_tasbih_target_a),
          (question: l.faqQ_tasbih_haptic_q, answer: l.faqQ_tasbih_haptic_a),
          (question: l.faqQ_tasbih_more_q, answer: l.faqQ_tasbih_more_a),
        ],
      ),
      (
        title: l.faqSectionManual,
        icon: Icons.edit_outlined,
        faqs: [
          (question: l.faqQ_manual_physical_q, answer: l.faqQ_manual_physical_a),
          (question: l.faqQ_manual_custom_q, answer: l.faqQ_manual_custom_a),
          (question: l.faqQ_manual_fix_q, answer: l.faqQ_manual_fix_a),
          (question: l.faqQ_manual_diff_q, answer: l.faqQ_manual_diff_a),
        ],
      ),
      (
        title: l.faqSectionStats,
        icon: Icons.bar_chart,
        faqs: [
          (question: l.faqQ_stats_goal_q, answer: l.faqQ_stats_goal_a),
          (question: l.faqQ_stats_streak_q, answer: l.faqQ_stats_streak_a),
        ],
      ),
      (
        title: l.faqSectionGroups,
        icon: Icons.group,
        faqs: [
          (question: l.faqQ_groups_join_q, answer: l.faqQ_groups_join_a),
          (question: l.faqQ_groups_create_q, answer: l.faqQ_groups_create_a),
          (question: l.faqQ_groups_admin_q, answer: l.faqQ_groups_admin_a),
        ],
      ),
      (
        title: l.faqSectionAccount,
        icon: Icons.person_outline,
        faqs: [
          (question: l.faqQ_account_guest_q, answer: l.faqQ_account_guest_a),
          (question: l.faqQ_account_changepw_q, answer: l.faqQ_account_changepw_a),
          (question: l.faqQ_account_forgotpw_q, answer: l.faqQ_account_forgotpw_a),
        ],
      ),
      (
        title: l.faqSectionData,
        icon: Icons.cloud_outlined,
        faqs: [
          (question: l.faqQ_data_cloud_q, answer: l.faqQ_data_cloud_a),
          (question: l.faqQ_data_picture_q, answer: l.faqQ_data_picture_a),
          (question: l.faqQ_data_theme_q, answer: l.faqQ_data_theme_a),
          (question: l.faqQ_data_language_q, answer: l.faqQ_data_language_a),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final l = AppL10n.of(context);
    final sections = _buildSections(l);

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(
        title: Text(l.profileHelpAndFaq),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(
          left: S.page,
          right: S.page,
          top: S.s24,
          bottom: S.s24 + bottomPad,
        ),
        itemCount: sections.length,
        itemBuilder: (context, sIdx) {
          final section = sections[sIdx];
          return FadeIn(
            delay: Duration(milliseconds: sIdx * 100),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: sIdx < sections.length - 1 ? S.s24 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(section.icon, size: 18, color: C.primary),
                      const SizedBox(width: S.s8),
                      Text(
                        section.title,
                        style: tt.titleSmall?.copyWith(
                          color: dark ? C.onDark1 : C.onLight1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: S.s12),
                  ...List.generate(section.faqs.length, (fIdx) {
                    final faq = section.faqs[fIdx];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: fIdx < section.faqs.length - 1 ? S.s8 : 0,
                      ),
                      child: _FaqTile(
                        question: faq.question,
                        answer: faq.answer,
                        dark: dark,
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.dark,
  });

  final String question;
  final String answer;
  final bool dark;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _iconTurns = Tween(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _iconCtrl.forward() : _iconCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dark = widget.dark;

    return Container(
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? C.darkDivider : C.lightDivider,
        ),
      ),
      child: Column(
        children: [
          // Question row
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: S.s16,
                vertical: S.s16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: dark ? C.onDark1 : C.onLight1,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: S.s16,
                      right: S.s16,
                      bottom: S.s16,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.answer,
                        style: tt.bodyMedium?.copyWith(
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
