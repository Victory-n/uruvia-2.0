import 'package:flutter/material.dart';

/// The colours that change between the Individual ("Fresh Growth") and
/// Business ("Trust and Control") accounts. Read it with
/// `Theme.of(context).extension<AppPalette>()!`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.hero,
    required this.action,
    required this.tint,
    required this.accent,
    required this.onAccent,
    required this.background,
  });

  final Color hero; // header and hero cards
  final Color action; // buttons, links, active states
  final Color tint; // soft backgrounds, selected rows, chips
  final Color accent; // highlights
  final Color onAccent; // text on the accent colour
  final Color background; // screen background

  static const individual = AppPalette(
    hero: Color(0xFF096240),
    action: Color(0xFF0B7A4B),
    tint: Color(0xFFE3F6EC),
    accent: Color(0xFFF5A623),
    onAccent: Color(0xFF101828),
    background: Color(0xFFF6FBF8),
  );

  static const business = AppPalette(
    hero: Color(0xFF0A3860),
    action: Color(0xFF0E4D86),
    tint: Color(0xFFE1EEF9),
    accent: Color(0xFF12B76A),
    onAccent: Color(0xFF052E1A),
    background: Color(0xFFF4F7FB),
  );

  @override
  AppPalette copyWith({
    Color? hero,
    Color? action,
    Color? tint,
    Color? accent,
    Color? onAccent,
    Color? background,
  }) =>
      AppPalette(
        hero: hero ?? this.hero,
        action: action ?? this.action,
        tint: tint ?? this.tint,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        background: background ?? this.background,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      hero: Color.lerp(hero, other.hero, t)!,
      action: Color.lerp(action, other.action, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
    );
  }
}

/// Neutral colours shared by both themes.
class AppColors {
  const AppColors._();

  static const ink = Color(0xFF101828); // headings, amounts
  static const inkSoft = Color(0xFF667085); // captions, helper text
  static const border = Color(0xFFE4E7EC); // inputs, dividers, card outlines
  static const surface = Colors.white;
  static const skeleton = Color(0xFFEAECF0);
  static const disabledFill = Color(0xFFF2F4F7);

  // Premium gold: Pro badges and upgrade banners.
  static const goldDark = Color(0xFFD4A017);
  static const goldLight = Color(0xFFF5C84C);

  // Soft backgrounds for status chips (text stays in StatusColors).
  static const successBg = Color(0xFFECFDF3);
  static const warningBg = Color(0xFFFFFAEB);
  static const errorBg = Color(0xFFFEF3F2);
  static const infoBg = Color(0xFFE6F5FC);
  static const infoText = Color(0xFF0B6A9A);
  static const neutralBg = Color(0xFFF2F4F7);
  static const neutralText = Color(0xFF475467);
}

/// Status colours shared by both themes.
class StatusColors {
  const StatusColors._();

  static const success = Color(0xFF067647);
  static const warning = Color(0xFFF79009);
  static const warningText = Color(0xFFB54708);
  static const error = Color(0xFFD92D20);
  static const errorText = Color(0xFFB42318);
  static const border = Color(0xFFEAECF0);
}
