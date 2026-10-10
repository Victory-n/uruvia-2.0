import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';
import 'tokens.dart';

/// Builds the app theme for one account type. Plus Jakarta Sans is used for
/// headings, Inter for body text and every figure. Widgets read styles from
/// `Theme.of(context).textTheme` and never call GoogleFonts themselves.
ThemeData buildTheme(AppPalette p) {
  const ink = AppColors.ink;
  final jakarta = GoogleFonts.plusJakartaSans;
  final inter = GoogleFonts.inter;

  final textTheme = GoogleFonts.interTextTheme().copyWith(
    // Display 32/40 700
    headlineLarge: jakarta(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700, color: ink),
    // Heading 1 24/32 700
    headlineMedium: jakarta(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, color: ink),
    // Heading 2 20/28 600
    headlineSmall: jakarta(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: ink),
    // Heading 3 18/26 600
    titleLarge: jakarta(fontSize: 18, height: 26 / 18, fontWeight: FontWeight.w600, color: ink),
    // Title 16/24 600
    titleMedium: inter(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, color: ink),
    // Body large 16/24 400
    bodyLarge: inter(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: ink),
    // Body 14/20 400
    bodyMedium: inter(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: ink),
    // Label 14/20 500 (buttons, chips, tabs)
    labelLarge: inter(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: ink),
    // Caption 12/16 400
    bodySmall: inter(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: AppColors.inkSoft),
    // Overline 11/16 600, +0.5 tracking
    labelSmall: inter(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.inkSoft,
    ),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control));

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.action,
      primary: p.action,
      surface: AppColors.surface,
      error: StatusColors.error,
    ),
    scaffoldBackgroundColor: p.background,
    textTheme: textTheme,
    extensions: [p],
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: p.hero,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.action,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, AppSpacing.buttonHeight),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.action,
        side: BorderSide(color: p.action, width: 1.5),
        minimumSize: const Size(64, AppSpacing.buttonHeight),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.action,
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: buttonShape,
      duration: const Duration(seconds: 4),
    ),
  );
}
