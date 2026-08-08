import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Colour tokens ─────────────────────────────────────────────────────────

  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _primaryGreenDark = Color(0xFF1B5E20);
  static const Color _primaryGreenLight = Color(0xFF4CAF50);

  // ─── Typography helpers ─────────────────────────────────────────────────────

  static TextTheme _buildTextTheme({required Brightness brightness}) {
    final bodyColor = brightness == Brightness.light
        ? const Color(0xFF263238)
        : const Color(0xFFECEFF1);
    final subtitleColor = brightness == Brightness.light
        ? const Color(0xFF455A64)
        : const Color(0xFFB0BEC5);
    final arabicHeadingColor = brightness == Brightness.light
        ? _primaryGreenDark
        : _primaryGreenLight;

    return TextTheme(
      // Amiri for Quran text and Arabic headings
      displayLarge: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: arabicHeadingColor,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: arabicHeadingColor,
      ),
      bodyLarge: GoogleFonts.amiri(
        fontSize: 18,
        color: bodyColor,
      ),
      // Cairo for UI labels and subtitles
      bodyMedium: GoogleFonts.cairo(
        fontSize: 16,
        color: subtitleColor,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 12,
        color: subtitleColor,
      ),
    );
  }

  // ─── Light Theme ───────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryGreen,
        onPrimary: Colors.white,
        secondary: _primaryGreenDark,
        onSecondary: Colors.white,
        tertiary: _primaryGreenLight,
        surface: Colors.white,
        onSurface: Color(0xFF263238),
        surfaceContainerHighest: Color(0xFFF5F5F5),
        error: Color(0xFFB00020),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(brightness: Brightness.light),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryGreenLight,
        onPrimary: Colors.black,
        secondary: _primaryGreen,
        onSecondary: Colors.white,
        tertiary: _primaryGreenDark,
        surface: Color(0xFF1E1E1E),
        onSurface: Color(0xFFECEFF1),
        surfaceContainerHighest: Color(0xFF121212),
        error: Color(0xFFCF6679),
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFECEFF1),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(brightness: Brightness.dark),
    );
  }
}
