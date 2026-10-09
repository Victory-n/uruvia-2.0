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
  });

  final Color hero; // header and hero cards
  final Color action; // buttons, links, active states
  final Color tint; // soft backgrounds
  final Color accent; // highlights
  final Color onAccent; // text on the accent colour

  static const individual = AppPalette(
    hero: Color(0xFF096240),
    action: Color(0xFF0B7A4B),
    tint: Color(0xFFE3F6EC),
    accent: Color(0xFFF5A623),
    onAccent: Color(0xFF101828),
  );

  static const business = AppPalette(
    hero: Color(0xFF0A3860),
    action: Color(0xFF0E4D86),
    tint: Color(0xFFE1EEF9),
    accent: Color(0xFF12B76A),
    onAccent: Color(0xFF052E1A),
  );

  @override
  AppPalette copyWith({
    Color? hero,
    Color? action,
    Color? tint,
    Color? accent,
    Color? onAccent,
  }) =>
      AppPalette(
        hero: hero ?? this.hero,
        action: action ?? this.action,
        tint: tint ?? this.tint,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
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
    );
  }
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
