import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: GoogleFonts.quicksandTextTheme().apply(
      bodyColor: AppColors.textColor,
    ),
    appBarTheme: appBarTheme(),
    useMaterial3: true,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: AppColors.backgroundColor,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColors.textColor),
    titleTextStyle: GoogleFonts.quicksand(
      color: AppColors.textColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    actionsIconTheme: IconThemeData(color: AppColors.textColor),
  );
}

class AppColors {
  static const Color themeColor = Color(0xFF5257A5);
  static const Color backgroundColor = Color(0xFF010213);
  static const Color textColor = Colors.white;
  static const Color navButtonsColor = Color(0xFF0F0F0F);
  static const Color secondaryColor = Color(0xFF1E1E2A);
  static const Color buttonColor = Color(0xFF3E3E4A);
  static const Color tertiaryColor = Color(0xFF272442);
}
