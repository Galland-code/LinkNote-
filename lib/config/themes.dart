import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  /// Light theme for the app
  static ThemeData get lightTheme => ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: const Color(0xFFFDF9ED),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.black,
      secondary: const Color(0xFFBD3751),
    ),
  );
}