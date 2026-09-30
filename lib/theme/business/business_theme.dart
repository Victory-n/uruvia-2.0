import 'package:flutter/material.dart';

/// Business account design system.
///
/// Palette: Deep charcoal + warm amber � professional, authoritative, distinct
/// from the individual account's green/navy palette.
class BusinessTheme {
  // -- Brand Colors ----------------------------------------------------------
  /// Primary amber/gold � the signature business accent
  static const Color primaryAmber = Color.fromARGB(255, 5, 126, 202);

  /// Deep charcoal � replaces sleekBlue for backgrounds/buttons
  static const Color charcoal = Color(0xFF1C1917);

  /// Dark warm brown � used for text on light surfaces
  static const Color textDark = Color(0xFF292524);

  /// Muted warm grey � secondary / hint text
  static const Color textMuted = Color(0xFF78716C);

  /// Very light warm cream background
  static const Color backgroundLight = Color(0xFFFAF9F7);

  /// Surface card color
  static const Color surface = Color(0xFFFFFFFF);

  /// Danger / error red (unchanged from individual, still standard)
  static const Color danger = Color(0xFFEF4444);

  /// Success green
  static const Color success = Color(0xFF22C55E);

  static const Color white = Colors.white;

  // -- ThemeData -------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: charcoal,
        secondary: primaryAmber,
        surface: surface,
        onPrimary: white,
        onSecondary: charcoal,
        onSurface: textDark,
        error: danger,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textDark),
        bodyMedium: TextStyle(fontSize: 14, color: textMuted),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoal,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryAmber, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textMuted),
        floatingLabelStyle: const TextStyle(color: primaryAmber),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7E5E4),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F4),
        labelStyle: const TextStyle(color: textDark, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
