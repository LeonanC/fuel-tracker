import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF3366FF),
        brightness: Brightness.light,
        surface: Colors.white,
        surfaceVariant: Color(0xFFF1F5F9),
        onSurfaceVariant: Color(0xFF334155),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Color(0xFFF1F5F9),
        filled: true,
        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: ColorScheme.fromSeed(
        primary: Color.fromARGB(255, 20, 130, 219),
        onPrimary: Color.fromARGB(255, 246, 246, 247),
        secondary: Color(0xFF3366FF),
        seedColor: Color(0xFF3366FF),
        brightness: Brightness.dark,
        surface: Color(0xFF1E293B),
        surfaceVariant: Color(0xFF334155),
        onSurfaceVariant: Color(0xFFE2E8F0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Color(0xFF1E293B),
        filled: true,
        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }
}
