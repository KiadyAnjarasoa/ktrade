import 'package:flutter/material.dart';

class KTradeTheme {
  static const Color background = Color(0xFF0D0F12);
  static const Color cardBackground = Color(0xFF161A20);
  static const Color primaryGreen = Color(0xFF00E676);
  static const Color lossRed = Color(0xFFFF5252);
  static const Color warningOrange = Color(0xFFFFAB00);
  static const Color textMuted = Color(0xFF8A92A6);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        surface: cardBackground,
        error: lossRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData( // 👈 Fix CardThemeData
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222832), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}