/// Spacing, sizes and corner radii from the design reference. Everything sits on a 4 pt grid.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Side margin of a screen (16 on screens narrower than 360).
  static const double pageMargin = 20;
  static const double cardPadding = 16;
  static const double sectionGap = 24;
  static const double minTouchTarget = 48;
  static const double buttonHeight = 52;
}

class AppRadius {
  const AppRadius._();

  static const double chip = 8;
  static const double control = 12; // buttons and inputs
  static const double card = 16;
  static const double sheet = 24; // top corners of bottom sheets
}

class AppDurations {
  const AppDurations._();

  static const quick = Duration(milliseconds: 200);
  static const sheet = Duration(milliseconds: 300);
  static const accountSwitch = Duration(milliseconds: 300);
  static const success = Duration(milliseconds: 600);
}
