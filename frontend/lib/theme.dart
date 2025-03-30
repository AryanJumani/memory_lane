import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFF0f0f1f),
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(255, 78, 93, 129),
    secondary: Color.fromRGBO(86, 102, 142, 1),
    surface: Color.fromARGB(255, 34, 44, 60),
    onPrimary: Color(0xFFd5d5e2),
    onSecondary: Color(0xFFadadc7),
    onSurface: Color.fromARGB(255, 134, 152, 172),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 46, 55, 77),
      foregroundColor: Color(0xFFd5d5e2),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color.fromARGB(255, 46, 55, 77),
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
