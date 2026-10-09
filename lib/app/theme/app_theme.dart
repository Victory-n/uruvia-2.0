import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

ThemeData buildTheme(AppPalette p) {
  final base = GoogleFonts.interTextTheme();
  final heading = GoogleFonts.plusJakartaSans;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.action,
      primary: p.action,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: base.copyWith(
      headlineLarge: heading(fontSize: 32, fontWeight: FontWeight.w800),
      headlineMedium: heading(fontSize: 24, fontWeight: FontWeight.w800),
      titleLarge: heading(fontSize: 18, fontWeight: FontWeight.w700),
    ),
    extensions: [p],
  );
}
