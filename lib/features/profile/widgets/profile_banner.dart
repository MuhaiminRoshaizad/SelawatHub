import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

// ─────────────────────────────────────────────────────────
//  Banner with avatar, pattern overlay, edit button
// ─────────────────────────────────────────────────────────

class ProfileBanner extends StatelessWidget {
  const ProfileBanner({
    super.key,
    required this.dark,
    required this.tt,
    required this.topPad,
    required this.isGuest,
    required this.avatarUrl,
    required this.initials,
    required this.accent,
    required this.onEditTap,
    this.onAvatarTap,
  });

  final bool dark;
  final TextTheme tt;
  final double topPad;
  final bool isGuest;
  final String? avatarUrl;
  final String initials;
  final Color accent;
  final VoidCallback onEditTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    const bannerBody = 160.0;
    const avatarSize = 96.0;
    const avatarOverlap = avatarSize / 2;
    final bannerH = topPad + bannerBody;

    return SizedBox(
      height: bannerH + avatarOverlap + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient banner with curved bottom
          ClipPath(
            clipper: CurvedBannerClipper(),
            child: Container(
              height: bannerH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [
                          C.primaryMuted,
                          const Color(0xFF1A3D28),
                        ]
                      : [
                          C.primary,
                          C.primarySoft,
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Geometric pattern overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: IslamicPatternPainter(
                        color: C.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // "Profile" title
                  Positioned(
                    top: topPad + 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Profile',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: C.white,
                        ),
                      ),
                    ),
                  ),
                  // Edit pen in top-right
                  if (!isGuest)
                  Positioned(
                    top: topPad + 8,
                    right: S.s16,
                    child: BounceTap(
                      onTap: onEditTap,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: C.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.pencil,
                          size: 18,
                          color: C.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar overlapping the banner
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: dark ? C.dark1 : C.light1,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? C.dark1 : C.light1,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: C.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.15),
                        C.goldGlow,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isGuest
                        ? const Text(
                            '👤',
                            style: TextStyle(fontSize: 30),
                          )
                        : avatarUrl != null && avatarUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  avatarUrl!,
                                  width: avatarSize - 8,
                                  height: avatarSize - 8,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                  ),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Curved banner clipper
// ─────────────────────────────────────────────────────────

class CurvedBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width / 2, size.height + 20,
        size.width, size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────
//  Islamic geometric pattern painter (subtle overlay)
// ─────────────────────────────────────────────────────────

class IslamicPatternPainter extends CustomPainter {
  IslamicPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 40.0;
    const radius = 16.0;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        _drawStar(canvas, Offset(x, y), radius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const points = 8;
    final innerR = r * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final rad = i.isEven ? r : innerR;
      final x = center.dx + rad * cos(angle);
      final y = center.dy + rad * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
