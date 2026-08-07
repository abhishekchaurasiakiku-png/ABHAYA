import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF120E1F);
  static const Color surface = Color(0xFF1C152B);
  static const Color cardDark = Color(0xFF251C37);
  static const Color cardBorder = Color(0xFF4A3B69);
  static const Color sosPink = Color(0xFFFF3366);
  static const Color neonCyan = Color(0xFF00E5FF); // Kept for legacy/minor accents if needed
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color accentPink = Color(0xFFFF758F);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA594BD);
  static const Color navBar = Color(0xFF120E1F);
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
