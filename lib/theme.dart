import 'package:flutter/material.dart';

// ── Brand colours ─────────────────────────────────────────────────────────────
const kAccent      = Color(0xFF7F77DD);
const kAccentLight = Color(0xFFEEEDFE);
const kSidebarBg   = Color(0xFF1E1E2E);
const kSidebarText = Color(0xFFC8C8D8);
const kAppBg       = Color(0xFFF5F4F0);
const kCardBg      = Colors.white;
const kTextMain    = Color(0xFF1A1A2E);
const kTextMuted   = Color(0xFF888780);
const kTeal        = Color(0xFF1D9E75);
const kTealLight   = Color(0xFFE1F5EE);
const kAmber       = Color(0xFFBA7517);
const kAmberLight  = Color(0xFFFAEEDA);
const kCoral       = Color(0xFFD85A30);
const kCoralLight  = Color(0xFFFAECE7);
const kBorder      = Color(0x17000000);

// ── Avatar colours ────────────────────────────────────────────────────────────
const kAvatarColors = [
  (bg: Color(0xFFAFA9EC), text: Color(0xFF3C3489)), // purple – Minh
  (bg: Color(0xFF5DCAA5), text: Color(0xFF085041)), // teal   – An
  (bg: Color(0xFFF0997B), text: Color(0xFF4A1B0C)), // coral  – Linh
  (bg: Color(0xFFD3D1C7), text: Color(0xFF5F5E5A)), // grey   – default
];

// ── Reusable widgets ──────────────────────────────────────────────────────────

/// Small coloured badge (status)
class AppBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const AppBadge({super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
      );
}

/// Round avatar with initials
class AppAvatar extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double size;
  const AppAvatar({super.key, required this.initials, this.colorIndex = 0, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final c = kAvatarColors[colorIndex.clamp(0, kAvatarColors.length - 1)];
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: c.bg, shape: BoxShape.circle),
      child: Center(
        child: Text(initials,
            style: TextStyle(fontSize: size * 0.34, fontWeight: FontWeight.w600, color: c.text)),
      ),
    );
  }
}

/// White card with subtle border
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  const AppCard({super.key, required this.child, this.padding, this.radius = 12});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: kBorder, width: 0.5),
        ),
        child: child,
      );
}

// ── Status helpers ────────────────────────────────────────────────────────────
({Color bg, Color fg, String label}) statusStyle(String s) => switch (s) {
      'done'  => (bg: kTealLight,  fg: kTeal,  label: 'Hoàn thành'),
      'doing' => (bg: kAmberLight, fg: kAmber, label: 'Đang làm'),
      _       => (bg: kAccentLight, fg: kAccent, label: 'Chờ làm'),
    };

int avatarIndex(String initials) => switch (initials) {
      'MH' => 0,
      'AN' => 1,
      'TL' => 2,
      _    => 3,
    };
