import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/screens/theme_screen.dart';

void main() {
  testWidgets('ThemeScreen 컬러 swatch 텍스트가 항상 충분한 대비를 가진다', (WidgetTester tester) async {
    // 라이트 모드
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: const ThemeScreen(),
      ),
    );
    // 주요 컬러 swatch 텍스트가 검정 또는 흰색인지 확인
    expect(
      tester.widget<Text>(find.text('primary')).style?.color,
      anyOf(Colors.black, Colors.white),
    );
    // 다크 모드
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const ThemeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('primary')).style?.color,
      anyOf(Colors.black, Colors.white),
    );
  });
}
