import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor =
      const Color.fromRGBO(30, 187, 215, 1); // Base color: #1ebbd7
  static Color primaryAccent =
      const Color.fromRGBO(20, 158, 182, 1); // A darker shade of the base color
  static Color secondaryColor =
      const Color.fromRGBO(48, 48, 48, 1); // Neutral dark gray for contrast
  static Color secondaryAccent =
      const Color.fromRGBO(38, 38, 38, 1); // Slightly darker neutral gray
  static Color titleColor =
      const Color.fromRGBO(240, 240, 240, 1); // Light gray for titles
  static Color textColor =
      const Color.fromRGBO(180, 180, 180, 1); // Medium gray for readable text
  static Color successColor = const Color.fromRGBO(14, 174, 106, 1);
  static Color highlightColor = const Color.fromRGBO(255, 202, 40, 1);
}

ThemeData primaryTheme = ThemeData(
  // seed color theme
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
  ),

  // scaffold color
  scaffoldBackgroundColor: AppColors.secondaryAccent,

  // app bar theme colors
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.secondaryColor,
    foregroundColor: AppColors.textColor,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  ),

  // text theme
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: AppColors.textColor,
      fontSize: 16,
      letterSpacing: 1,
    ),
    headlineMedium: TextStyle(
      color: AppColors.titleColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
    titleMedium: TextStyle(
      color: AppColors.titleColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  ),

  // card theme
  cardTheme: CardTheme(
    color: AppColors.secondaryColor.withOpacity(0.5),
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(),
    shadowColor: Colors.transparent,
    margin: const EdgeInsets.only(bottom: 16),
  ),
);
