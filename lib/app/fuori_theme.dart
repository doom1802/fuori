import 'package:flutter/material.dart';

abstract final class FuoriColors {
  static const paper = Color(0xFFFAF9F6);
  static const ink = Color(0xFF202126);
  static const muted = Color(0xFF73746F);
  static const surface = Color(0xFFFFFFFF);
  static const wash = Color(0xFFEEEEE8);
  static const line = Color(0xFFE5E5DF);
  static const coral = Color(0xFFC63E28);
  static const peach = Color(0xFFF6DFCA);
  static const lilac = Color(0xFFE8E3F5);

  static const darkPaper = Color(0xFF191A1E);
  static const darkSurface = Color(0xFF24262B);
  static const darkWash = Color(0xFF303238);
  static const darkLine = Color(0xFF393B40);
  static const darkCoral = Color(0xFFFF9987);
}

abstract final class FuoriTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF4F3EF) : FuoriColors.ink;
    final paper = dark ? FuoriColors.darkPaper : FuoriColors.paper;
    final surface = dark ? FuoriColors.darkSurface : FuoriColors.surface;
    final accent = dark ? FuoriColors.darkCoral : FuoriColors.coral;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'DM Sans',
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: brightness,
        primary: accent,
        onPrimary: dark ? const Color(0xFF29140F) : Colors.white,
        surface: surface,
        onSurface: ink,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 40,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.2,
          color: ink,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 34,
          height: 1.12,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.7,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 24,
          height: 1.16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: ink),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: dark ? const Color(0xFFB1B1AB) : FuoriColors.muted,
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

extension FuoriThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get paper => isDark ? FuoriColors.darkPaper : FuoriColors.paper;
  Color get surface => isDark ? FuoriColors.darkSurface : FuoriColors.surface;
  Color get wash => isDark ? FuoriColors.darkWash : FuoriColors.wash;
  Color get line => isDark ? FuoriColors.darkLine : FuoriColors.line;
  Color get accent => isDark ? FuoriColors.darkCoral : FuoriColors.coral;
  Color get peach => isDark ? const Color(0xFF483B34) : FuoriColors.peach;
  Color get lilac => isDark ? const Color(0xFF39334B) : FuoriColors.lilac;
}
