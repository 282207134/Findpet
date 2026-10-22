import 'package:flutter/material.dart';

const ink = Color(0xFF155157);
const orange = Color(0xFFFFB547);
const muted = Color(0xFF929C9E);
const cream = Color(0xFFFFF4DD);
const blue = Color(0xFF4779F5);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: ink,
    primary: ink,
    secondary: orange,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    bodyMedium: TextStyle(fontSize: 13, height: 1.7, color: ink),
    bodySmall: TextStyle(fontSize: 11, height: 1.6, color: muted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: Color(0xFFB6BABC), fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: orange),
    ),
    errorStyle: const TextStyle(fontSize: 11),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: orange,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 58),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ink),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: ink,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFF1F1F1)),
);
