import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFFDBB3B1);
  static const Color accentColor = Color(0xFFC89FA3);
  static const Color borderColor = Color(0xFFA67F8E);
  static const Color textPrimary = Color(0xFF2C1A1D);
  static const Color textSecondary = Color(0xFF6C534E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFFDF8F7);

  static Color get primary => primaryColor;
  static Color get primaryDark => const Color(0xFFC49A96);
  static Color get accent => accentColor;
  static Color get background => scaffoldBg;

  static ThemeData light() {
    final moonTokens = MoonTokens.light.copyWith(
      colors: MoonColors.light.copyWith(
        piccolo: primaryColor,
        hit: accentColor,
        beerus: borderColor,
        goku: scaffoldBg,
        gohan: white,
        bulma: textPrimary,
        trunks: textSecondary,
        goten: white,
        popo: white,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ),
    );

    final moonTheme = MoonTheme(tokens: moonTokens);

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: moonTokens.colors.goku,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: white,
        onPrimary: white,
        onSecondary: white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: moonTokens.colors.goku,
        foregroundColor: moonTokens.colors.bulma,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: moonTokens.colors.gohan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: accentColor,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primaryColor, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: textSecondary);
        }),
      ),
      extensions: <ThemeExtension<dynamic>>[
        moonTheme,
      ],
    );
  }
}
