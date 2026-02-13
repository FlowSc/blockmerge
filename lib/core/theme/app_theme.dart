import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color primaryColor = Color(0xFF00E5FF);
  static const Color backgroundColor = Color(0xFF0B0B1A);
  static const Color surfaceColor = Color(0xFF1C1C3A);
  static const Color accentColor = Color(0xFFFF6EC7);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'PressStart2P',
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'PressStart2P',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'PressStart2P',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PressStart2P',
          color: Colors.white70,
          fontSize: 10,
        ),
      ),
    );
  }
}
