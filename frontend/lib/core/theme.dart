import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color cardBorder = Color(0xFF2A2D5E);
  static const Color sosPink = Color(0xFFFF2D55);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFBB86FC);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8E8EA0);
  static const Color navBar = Color(0xFF0D1025);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.sosPink,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sosPink,
        secondary: AppColors.neonCyan,
        surface: AppColors.surface,
        onSurface: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
