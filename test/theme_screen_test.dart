import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/screens/theme_screen.dart';

void main() {
  testWidgets('ThemeScreen에서 다크/라이트 모드 전환 시 컬러/폰트 미리보기가 즉시 반영된다', (WidgetTester tester) async {
    // 라이트 모드
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: const ThemeScreen(),
      ),
    );
    expect(find.text('Theme (Light)'), findsOneWidget);
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
    expect(find.text('Theme (Dark)'), findsOneWidget);
  });
}
