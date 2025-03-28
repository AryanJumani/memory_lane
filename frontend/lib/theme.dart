import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFF0f0f1f),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF3f3f6a),
    secondary: Color(0xFF61618f),
    surface: Color(0xFF22223c),
    onPrimary: Color(0xFFd5d5e2),
    onSecondary: Color(0xFFadadc7),
    onSurface: Color(0xFF8686ac),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF3f3f6a),
      foregroundColor: Color(0xFFd5d5e2),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF22223c),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xFF61618f)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF8686ac), width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    hintStyle: TextStyle(color: Color(0xFFadadc7)),
    labelStyle: TextStyle(color: Color(0xFFd5d5e2)),
  ),
);
