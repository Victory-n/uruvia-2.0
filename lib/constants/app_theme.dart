import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';

/// Design system tokens inspired by the precision, structural discipline,
/// and institutional authority of Theme A, optimized for Uruvia's mobile fintech workflow.
class AppColors {
  // Brand Primaries
  static const Color primaryNavy = Color(0xFF0B1C30);
  static const Color brandBlue = Color(0xFF0058BE);
  static const Color brandBlueLight = Color(0xFFEFF6FF);
  static const Color brandBlueDark = Color(0xFF003C8F);

  // Institutional Accents (Theme A subtle warmth)
  static const Color secondaryGold = Color(0xFF745B1C);
  static const Color secondaryGoldLight = Color(0xFFFFF7E6);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8F9FF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF1F4F9);
  static const Color surfaceContainerHigh = Color(0xFFE7EBF2);

  // Hairlines & Drafting Borders (Theme A signature)
  static const Color borderHairline = Color(0xFFE2E8F0);
  static const Color borderHairlineSubtle = Color(0xFFEEF1F6);
  static const Color borderHairlineDark = Color(0xFFCBD5E1);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF45464D);
  static const Color textMuted = Color(0xFF76777D);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Telemetry
  static const Color success = Color(0xFF0E703C);
  static const Color successContainer = Color(0xFFE8F7EE);
  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFEBE8);
}

/// Typographic tokens uniting editorial authority with technical HUD precision.
class AppTypography {
  static const String primaryFont = 'WorkSans';
  static const String secondaryFont = 'Inter';

  // --- Display & Headlines ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Body Copy ---
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // --- Theme A Signature: Technical HUD / Metadata Label Caps ---
  static const TextStyle labelCaps = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );

  static const TextStyle labelCapsEmphasized = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.brandBlue,
  );

  // --- Financial Monospaced / Numeric Telemetry ---
  static const TextStyle financialMetric = TextStyle(
    fontFamily: primaryFont,
    fontSize: 26.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
}

/// Global Application Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.primaryFont,
      scaffoldBackgroundColor: ConstantColor.lightBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.brandBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandBlueLight,
        onPrimaryContainer: AppColors.primaryNavy,
        secondary: AppColors.primaryNavy,
        onSecondary: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderHairline,
        outlineVariant: AppColors.borderHairlineSubtle,
      ),

      // App Bar: Flat, clean, structural
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ConstantColor.lightBackground,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.primaryFont,
          fontSize: 17.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      // Card Theme: Crisp 10px radius with 1px architectural hairline
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(
            color: AppColors.borderHairline,
            width: 1.0,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Primary Action Button (Modern Rectangular with gentle 10px curve)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.primaryFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),

      // Outlined Structural Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(
            color: AppColors.borderHairlineDark,
            width: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.primaryFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Inputs & Text Fields: Structural, high legibility
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: AppTypography.primaryFont,
          fontSize: 14.0,
          color: AppColors.textMuted,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppTypography.primaryFont,
          fontSize: 14.0,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: AppColors.borderHairline,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: AppColors.borderHairline,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: AppColors.brandBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.0,
          ),
        ),
      ),

      // Hairline Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.borderHairline,
        thickness: 1.0,
        space: 1.0,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        headlineMedium: AppTypography.headlineMedium,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelSmall: AppTypography.labelCaps,
      ),
    );
  }
}
