import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  static const _faqs = [
    (
      question: 'How do I count selawat?',
      answer:
          'Go to the Tasbih tab and tap anywhere on the screen to count. You can select different selawat and zikir from the bottom sheet.',
    ),
    (
      question: 'How do I join a group?',
      answer:
          'Go to the Group tab and enter the invite code shared by your group leader. Tap \'Join Group\' to join.',
    ),
    (
      question: 'How do I create a group?',
      answer:
          'Go to the Group tab and tap \'Create New Group\'. Enter a group name and optional description.',
    ),
    (
      question: 'How do I change my daily goal?',
      answer:
          'Go to the Group tab, tap the settings icon, and update the daily goal in group settings.',
    ),
    (
      question: 'Can I track specific selawat?',
      answer:
          'Yes! The Stats tab shows your activity breakdown by selawat and zikir type.',
    ),
    (
      question: 'Is my data saved?',
      answer:
          'Currently, data is stored locally on your device. Cloud sync is coming soon!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: S.page,
          vertical: S.s24,
        ),
        itemCount: _faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: S.s12),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return FadeIn(
            delay: Duration(milliseconds: index * 80),
            child: _FaqTile(
              question: faq.question,
              answer: faq.answer,
              dark: dark,
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
