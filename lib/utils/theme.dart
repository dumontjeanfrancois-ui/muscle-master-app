import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryDark = Color(0xFF0A0E27);
  static const Color cardDark = Color(0xFF1A1F3A);
  static const Color secondaryDark = Color(0xFF252B4A);
  static const Color surfaceDark = Color(0xFF1A1F3A); // Alias pour cardDark
  static const Color backgroundLight = Color(0xFF141829); // Couleur de fond légèrement plus claire
  
  // Couleurs néon
  static const Color neonBlue = Color(0xFF4A90E2);
  static const Color neonPurple = Color(0xFFB24BF3);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF6B35);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonRed = Color(0xFFFF4444);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C8);
  static const Color textDisabled = Color(0xFF6B7280);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: neonBlue,
    scaffoldBackgroundColor: primaryDark,
    cardColor: cardDark,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      elevation: 0,
      centerTitle: true,
    ),
    
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: neonBlue.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textDisabled.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonBlue, width: 2),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: neonBlue,
      unselectedItemColor: textSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
