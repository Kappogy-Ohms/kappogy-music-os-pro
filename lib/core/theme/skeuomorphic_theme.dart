import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/skeuo_scrollbar.dart';

/// Master Theme Builder for Kappogy Music OS Pro
enum AppThemeMode { skeuomorphicDark, amoledMidnight, retroWin95, cyberNeon }

class KappogyTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.skeuomorphicDark:
        return _buildSkeuomorphicDark();
      case AppThemeMode.amoledMidnight:
        return _buildAmoledMidnight();
      case AppThemeMode.retroWin95:
        return _buildRetroWin95();
      case AppThemeMode.cyberNeon:
        return _buildCyberNeon();
    }
  }

  static ThemeData _buildSkeuomorphicDark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.chassisBg,
      primaryColor: AppColors.kappogyRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kappogyRed,
        secondary: AppColors.kappogyYellow,
        tertiary: AppColors.kappogyGreen,
        surface: AppColors.chassisSurface,
        surfaceContainerHighest: AppColors.panelRaised,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        titleLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        bodyLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
      scrollbarTheme: KappogyScrollbarTheme.theme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.chassisBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData _buildAmoledMidnight() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.black,
      primaryColor: AppColors.ledCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.ledCyan,
        secondary: AppColors.ledPurple,
        surface: Color(0xFF0A0A0A),
        surfaceContainerHighest: Color(0xFF141414),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scrollbarTheme: KappogyScrollbarTheme.theme,
    );
  }

  static ThemeData _buildRetroWin95() {
    final base = ThemeData.light(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF008080), // Classic Teal
      primaryColor: const Color(0xFF000080), // Navy
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF000080),
        surface: Color(0xFFC0C0C0),
      ),
      scrollbarTheme: KappogyScrollbarTheme.theme,
    );
  }

  static ThemeData _buildCyberNeon() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0D0B18),
      primaryColor: const Color(0xFFFF007F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF007F),
        secondary: Color(0xFF00F0FF),
        surface: Color(0xFF161226),
      ),
      textTheme: GoogleFonts.robotoMonoTextTheme(base.textTheme),
      scrollbarTheme: KappogyScrollbarTheme.theme,
    );
  }
}
