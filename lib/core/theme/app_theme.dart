import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color accentGold = Color(0xFFC9A227);
  static const Color surfaceDark = Color(0xFF0D1B12);
  static const Color cardDark = Color(0xFF1A2E22);

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentGold,
      surface: surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accentGold,
        thumbColor: accentGold,
        inactiveTrackColor: Color(0xFF2A4034),
      ),
    );
  }
}
