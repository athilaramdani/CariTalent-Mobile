import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const highlight = Color(0xFFB57AFF);
  static const accent = Color(0xFFE94057);
  static const uiDark = Color(0xFF16152B); // slightly darker to match the image
  static const neutralDark = Color(0xFF111827);
  static const neutralMedium = Color(0xFF6B7280);
  static const panel = Color(0x14FFFFFF);
  static const border = Color(0x1AFFFFFF);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: highlight,
      brightness: Brightness.dark,
    );

    final baseTextTheme = GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          height: 1.2,
        ),
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(
          color: Color(0xD9FFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xB3FFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(color: Color(0xA6FFFFFF)),
        labelLarge: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    // Apply Syne to headings/display text and titles
    final customTextTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.syne(textStyle: baseTextTheme.displayLarge),
      displayMedium: GoogleFonts.syne(textStyle: baseTextTheme.displayMedium),
      displaySmall: GoogleFonts.syne(textStyle: baseTextTheme.displaySmall),
      headlineLarge: GoogleFonts.syne(textStyle: baseTextTheme.headlineLarge),
      headlineMedium: GoogleFonts.syne(textStyle: baseTextTheme.headlineMedium),
      headlineSmall: GoogleFonts.syne(textStyle: baseTextTheme.headlineSmall),
      titleLarge: GoogleFonts.syne(textStyle: baseTextTheme.titleLarge),
      titleMedium: GoogleFonts.syne(textStyle: baseTextTheme.titleMedium),
      titleSmall: GoogleFonts.syne(textStyle: baseTextTheme.titleSmall),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF080714),
      fontFamily: GoogleFonts.dmSans().fontFamily,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: GoogleFonts.dmSans(color: const Color(0xB3FFFFFF)),
        hintStyle: GoogleFonts.dmSans(color: const Color(0x80FFFFFF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: highlight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: Colors.white,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      textTheme: customTextTheme,
    );
  }
}
