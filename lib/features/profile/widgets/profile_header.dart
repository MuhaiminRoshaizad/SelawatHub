import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

/// Minimal airy profile header — no banner, no title chrome.
/// Just a generous top spacer, a centered avatar with a soft accent
/// gradient ring and an edit badge, nothing else. Name + bio are
/// rendered separately below by the page so they can stay in sync
/// with any inline edit states.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.dark,
    required this.topPad,
    required this.isGuest,
    required this.avatarUrl,
    required this.initials,
    required this.accent,
    required this.onEditTap,
    this.onAvatarTap,
  });

  final bool dark;
  final double topPad;
  final bool isGuest;
  final String? avatarUrl;
  final String initials;
  final Color accent;
  final VoidCallback onEditTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    const avatarSize = 112.0;
    const ringWidth = 3.0;
    const innerSize = avatarSize - ringWidth * 2;

    return Padding(
      padding: EdgeInsets.only(top: topPad + S.s24, bottom: S.s8),
      child: Center(
        child: SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar with gradient ring
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent,
                        C.gold,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: dark ? 0.25 : 0.18),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(ringWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark ? C.dark1 : C.light1,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: _AvatarInner(
                        size: innerSize - 4,
                        dark: dark,
                        isGuest: isGuest,
                        avatarUrl: avatarUrl,
                        initials: initials,
                        accent: accent,
                      ),
                    ),
                  ),
                ),
              ),

              // Edit badge — bottom-right of the avatar
              if (!isGuest)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: BounceTap(
                    onTap: onEditTap,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? C.dark1 : C.light1,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: C.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.pencil,
                        size: 14,
                        color: C.white,
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

class _AvatarInner extends StatelessWidget {
  const _AvatarInner({
    required this.size,
    required this.dark,
    required this.isGuest,
    required this.avatarUrl,
    required this.initials,
    required this.accent,
  });

  final double size;
  final bool dark;
  final bool isGuest;
  final String? avatarUrl;
  final String initials;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.12),
              C.goldGlow,
            ],
          ),
        ),
        child: const Center(
          child: Text('👤', style: TextStyle(fontSize: 36)),
        ),
      );
    }

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.18),
            C.goldGlow,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ),
    );
  }
}
