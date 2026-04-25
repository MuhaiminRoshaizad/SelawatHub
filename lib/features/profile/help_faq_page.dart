import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  static const _sections = [
    (
      title: 'Tasbih & Counter',
      icon: Icons.touch_app,
      faqs: [
        (
          question: 'How do I count selawat or zikir?',
          answer:
              'Go to the Tasbih tab and tap the counter area to count. You can switch between different selawat and zikir types by tapping the dhikr name at the top. There are two counter styles available — digital and bead — which you can switch in the counter settings.',
        ),
        (
          question: 'How do I change the dhikr type?',
          answer:
              'On the Tasbih tab, tap the dhikr name displayed at the top of the counter. A selector sheet will appear where you can choose from various selawat and zikir types.',
        ),
        (
          question: 'Can I set a target count for my dhikr?',
          answer:
              'Yes! Go to the counter settings (⋮ menu on the Tasbih tab) and set your desired target count. The counter will track your progress toward that target. The target must be a whole number greater than zero.',
        ),
        (
          question: 'What is the ⋮ button at the top of the counter?',
          answer:
              'The ⋮ (more) button opens an action menu with three options:\n\n• Add manual count — log dhikr you completed on a physical tasbih\n• Edit today\'s log — fix a mistake in any of today\'s counts\n• Counter settings — bead style, haptics, target counts, and the daily goal\n\nLong-press the ⋮ to jump straight to today\'s log.',
        ),
      ],
    ),
    (
      title: 'Manual Entry & Corrections',
      icon: Icons.edit_outlined,
      faqs: [
        (
          question: 'I use a physical tasbih. Can I still log my counts?',
          answer:
              'Yes. Open the ⋮ menu on the Tasbih tab and choose "Add manual count". Pick the dhikr, enter how many you completed, and tap Save. The amount is added to today\'s total — exactly as if you had tapped the counter that many times.\n\nYou can use this multiple times a day. Each save is added on top of what is already counted.',
        ),
        (
          question: 'My selawat / zikir is not in the built-in list. Can I add my own?',
          answer:
              'Yes — but only if you are signed in. In the manual count sheet, tap "Add custom" and enter the name of your selawat or zikir, then choose whether it is a selawat or zikir. Your custom entry is saved to your account and shows up alongside the built-in list every time you open the manual count sheet.\n\nGuest users cannot create custom dhikr because the data needs to be saved to your account.',
        ),
        (
          question: 'I entered the wrong number. How do I fix it?',
          answer:
              'There are three ways to correct a manual count:\n\n• Undo (immediate) — right after you save a manual count, a toast appears at the top with an UNDO button. Tap it within 6 seconds to reverse the change.\n• Subtract mode — open the manual count sheet again, switch the toggle to "Subtract", and enter the amount you want to remove. The total is clamped at 0 so you can\'t go negative.\n• Edit today\'s log — open the ⋮ menu and pick "Edit today\'s log". Tap any row to set its exact total for today. This is the easiest fix if you missed the undo toast.\n\nThe stats page also has an "Edit today\'s log" shortcut card under the streak.',
        ),
        (
          question: 'How is "Add manual count" different from tapping the counter?',
          answer:
              'They are functionally the same — both add to your today\'s total for the chosen dhikr. The counter tap is a 1-by-1 increment for use during live dhikr. Manual count is for batches you completed away from the app (on a physical tasbih, in your head, etc.) and lets you choose any positive number in one go.',
        ),
      ],
    ),
    (
      title: 'Stats & Goals',
      icon: Icons.bar_chart,
      faqs: [
        (
          question: 'How do I set or change my daily goal?',
          answer:
              'Go to the Stats tab and tap the progress bar or the edit icon next to your daily goal. You can set any goal greater than zero. This goal is used to track your daily progress and streak.',
        ),
        (
          question: 'How are streaks calculated?',
          answer:
              'A streak counts consecutive days where you meet your daily goal. If you reach your daily goal today and did so yesterday, your streak continues. Missing a day resets it to zero.',
        ),
      ],
    ),
    (
      title: 'Groups',
      icon: Icons.group,
      faqs: [
        (
          question: 'How do I join a group?',
          answer:
              'Go to the Group tab and enter the invite code shared by your group leader. Tap "Join Group" to join. You can only be in one group at a time.',
        ),
        (
          question: 'How do I create a group?',
          answer:
              'Go to the Group tab and tap "Create New Group". Enter a group name and optional description. You\'ll become the group admin and receive an invite code to share with others.',
        ),
        (
          question: 'What can a group admin do?',
          answer:
              'Group admins can edit the group name, description, and daily goal. They can also promote members to admin, demote admins, and remove members from the group.',
        ),
      ],
    ),
    (
      title: 'Account & Security',
      icon: Icons.lock_outline,
      faqs: [
        (
          question: 'Can I use the app without an account?',
          answer:
              'Yes! You can use SelawatHub as a guest. Guest users can count dhikr and view statistics stored locally on their device. However, group features and cloud sync require a registered account. Guest data may be lost if the app is uninstalled.',
        ),
        (
          question: 'How do I change my password?',
          answer:
              'Go to Profile > Change Password. You\'ll need to verify your current password first, then enter and confirm your new password (minimum 6 characters). If you\'ve forgotten your current password, tap "Forgot your current password?" to receive a reset link via email.',
        ),
        (
          question: 'I forgot my password. How do I reset it?',
          answer:
              'On the sign-in page, tap "Forgot password?" and enter your email address. You\'ll receive an email with a link to reset your password. If you\'re already logged in, you can also trigger a reset from Profile > Change Password.',
        ),
      ],
    ),
    (
      title: 'Data & Preferences',
      icon: Icons.storage_outlined,
      faqs: [
        (
          question: 'Is my data saved to the cloud?',
          answer:
              'If you have an account, your dhikr counts, profile, and group data are synced to the cloud. Preferences like theme, haptic feedback, and daily goal are stored locally on your device. Guest data is stored locally only.',
        ),
        (
          question: 'How do I change my profile picture?',
          answer:
              'Go to Profile > Edit Profile and tap the camera icon or your current photo. You can upload a new image from your device. To remove your photo, tap the remove option in the photo picker.',
        ),
        (
          question: 'How do I switch between dark and light mode?',
          answer:
              'Go to Profile and toggle the theme switch in the Preferences section. Your theme preference is saved locally and persists across sessions.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(
          left: S.page,
          right: S.page,
          top: S.s24,
          bottom: S.s24 + bottomPad,
        ),
        itemCount: _sections.length,
        itemBuilder: (context, sIdx) {
          final section = _sections[sIdx];
          return FadeIn(
            delay: Duration(milliseconds: sIdx * 100),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: sIdx < _sections.length - 1 ? S.s24 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
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
                  // FAQ tiles
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
