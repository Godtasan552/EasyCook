import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData LightTheme = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue[700],

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
      bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        elevation: 2,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[600],
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[600]!, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[600]!, width: 2.0),
      ),
      fillColor: Colors.grey[50],
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: TextStyle(
        color: Colors.blue[600],
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
