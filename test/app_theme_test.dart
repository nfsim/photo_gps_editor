import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/constants/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme과 darkTheme가 ThemeData로 정상 생성된다', () {
      expect(AppTheme.lightTheme, isA<ThemeData>());
      expect(AppTheme.darkTheme, isA<ThemeData>());
    });

    test('lightTheme의 ColorScheme과 TextTheme 값이 올바르게 설정되어 있다', () {
      final colorScheme = AppTheme.lightTheme.colorScheme;
      final textTheme = AppTheme.lightTheme.textTheme;
      expect(colorScheme.primary, const Color(0xFF007AFF));
      expect(textTheme.headlineLarge?.fontSize, 24);
      expect(textTheme.headlineLarge?.fontWeight, FontWeight.bold);
    });

    test('darkTheme의 ColorScheme과 TextTheme 값이 올바르게 설정되어 있다', () {
      final colorScheme = AppTheme.darkTheme.colorScheme;
      final textTheme = AppTheme.darkTheme.textTheme;
      expect(colorScheme.primary, const Color(0xFF2196F3));
      expect(textTheme.headlineLarge?.fontSize, 24);
      expect(textTheme.headlineLarge?.fontWeight, FontWeight.bold);
    });
  });
}
