import 'package:flutter/material.dart';

class AppTheme {
  static const highlight = Color(0xFF8A2BE2);
  static const accent = Color(0xFF00BFFF);
  static const uiDark = Color(0xFF1E1B4B);
  static const neutralDark = Color(0xFF111827);
  static const neutralMedium = Color(0xFF6B7280);
  static const panel = Color(0x14FFFFFF);
  static const border = Color(0x1AFFFFFF);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: highlight,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: uiDark,
      fontFamily: 'DM Sans',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: const TextStyle(color: Color(0xB3FFFFFF)),
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
      textTheme: const TextTheme(
        displaySmall: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Color(0xD9FFFFFF)),
        bodyMedium: TextStyle(color: Color(0xB3FFFFFF)),
        bodySmall: TextStyle(color: Color(0xA6FFFFFF)),
      ),
    );
  }
}
