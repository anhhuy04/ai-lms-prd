import 'package:flutter/material.dart';

// App theme and shared color palette (moon + blue-green)
class AppColors {
  static const Color moon = Color(0xFFF5F7FA); // soft moon background
  static const Color deepMoon = Color(0xFFE9EEF3);
  static const Color teal = Color(0xFF0EA5A4); // primary blue-green
  static const Color tealDark = Color(0xFF0B7E7C);
  // ~12% opacity teal for accents
  static const Color teal12 = Color(0x1F0EA5A4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF04202A);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.teal,
  scaffoldBackgroundColor: AppColors.moon,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.teal,
    secondary: AppColors.tealDark,
    surface: AppColors.moon,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.moon,
    foregroundColor: AppColors.textPrimary,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    centerTitle: false,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.teal,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
  ),
);

// Backwards-compatible wrapper expected by existing code (e.g. `AppTheme.lightTheme`)
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => appTheme;
}
