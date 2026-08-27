import 'package:flutter/material.dart';

/// Data model representing a single onboarding slide.
class OnboardingPageModel {
  final String badgeText;
  final String title;
  final String subtitle;
  final Widget graphicWidget;
  final List<Color> gradientColors;

  const OnboardingPageModel({
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.graphicWidget,
    required this.gradientColors,
  });
}
