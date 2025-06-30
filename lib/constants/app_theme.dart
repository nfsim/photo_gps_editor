import 'package:flutter/material.dart';

class AppTheme {
  // 기본 모드 테마
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF007AFF),
      onPrimary: Colors.white,
      secondary: Color(0xFFFF9500),
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF333333),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF444444)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF888888)),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  // 다크 모드 테마
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFFFF4081),
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE0E0E0),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE0E0E0)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFCCCCCC)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}
