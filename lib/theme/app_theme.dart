import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class AppTheme {
  // Kanso grayscale palette (exactly 5 shades as specified)
  static const Color pureBlack = Color(0xFF000000);      // #000000
  static const Color darkGray = Color(0xFF333333);       // #333333
  static const Color mediumGray = Color(0xFF777777);     // #777777
  static const Color lightGray = Color(0xFFBBBBBB);      // #BBBBBB
  static const Color pureWhite = Color(0xFFFFFFFF);      // #FFFFFF

  static ThemeData createTheme(ThemeService themeService) {
    final palette = themeService.generatedPalette;
    final pureBlack = palette[0];
    final darkGray = palette[1];
    final mediumGray = palette[2];
    final lightGray = palette[3];
    final pureWhite = palette[4];

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: pureBlack,
        secondary: darkGray,
        surface: lightGray, // Changed to light grey
        background: pureWhite,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: pureBlack,
        onBackground: pureBlack,
      ),
      scaffoldBackgroundColor: lightGray, // Changed to light grey
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500, // Medium weight for titles
          color: pureBlack,
          letterSpacing: -0.5,
          fontFamily: 'SF Pro Display', // Clean sans-serif
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          letterSpacing: -0.25,
          fontFamily: 'SF Pro Display',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkGray,
          fontFamily: 'SF Pro Display',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300, // Light weight for content
          color: pureBlack,
          fontFamily: 'SF Pro Text',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: darkGray,
          fontFamily: 'SF Pro Text',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: mediumGray,
          fontFamily: 'SF Pro Text',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pureBlack,
          foregroundColor: pureWhite,
          elevation: 0, // No shadows
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Flat, geometric
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pureBlack,
          side: BorderSide(color: pureBlack, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: pureBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: lightGray),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: lightGray),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: pureBlack, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: pureWhite,
        filled: true,
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0, // No shadows
        shape: RoundedRectangleBorder(
          side: BorderSide(color: lightGray, width: 1),
          borderRadius: BorderRadius.zero,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: pureBlack,
        elevation: 0, // No shadows
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: pureBlack,
          fontFamily: 'SF Pro Display',
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: pureBlack,
        unselectedItemColor: mediumGray,
        elevation: 0, // No shadows
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
