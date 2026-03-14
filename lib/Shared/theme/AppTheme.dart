import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    primaryColor: const Color(0xFF007CFE),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1E293B)),
        bodyMedium: TextStyle(color: Color(0xFF1E293B)),
        titleLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
    ),
  );
}
