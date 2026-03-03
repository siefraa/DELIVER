import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ================= LIGHT THEME =================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey.shade100,

      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      appBarTheme: _appBarTheme,
    );
  }

  // ================= DARK THEME =================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,

      cardTheme: _darkCardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      appBarTheme: _darkAppBarTheme,
    );
  }

  // ================= CARD THEME =================

  static const CardTheme _cardTheme = CardTheme(
    elevation: 4,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static const CardTheme _darkCardTheme = CardTheme(
    elevation: 4,
    margin: EdgeInsets.all(8),
    color: Colors.grey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  // ================= BUTTON THEME =================

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // ================= INPUT THEME =================

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.white,
  );

  static final InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.grey.shade800,
  );

  // ================= APPBAR THEME =================

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  );
}