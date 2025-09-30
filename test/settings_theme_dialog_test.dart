import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:photo_gps_editor/providers/font_provider.dart';
import 'package:photo_gps_editor/providers/theme_provider.dart';
import 'package:photo_gps_editor/screens/settings/settings_screen.dart';
import 'package:photo_gps_editor/screens/settings/theme_screen.dart';

void main() {
  testWidgets('ThemeScreen에서 현재 선택된 theme에 체크(v) 표시 및 변경', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FontProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ThemeScreen())),
            child: const Text('Go Theme'),
          ),
        )),
      ),
    );
    // ThemeScreen 진입
    await tester.tap(find.text('Go Theme'));
    await tester.pumpAndSettle();
    // ThemeMode 목록 존재
    expect(find.widgetWithText(ListTile, 'System'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Light'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Dark'), findsOneWidget);
    // 기본값 System에 체크(v) 아이콘 존재
    final systemOption = find.widgetWithText(ListTile, 'System');
    expect(
      find.descendant(of: systemOption, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    // Light 선택 시 체크가 이동
    await tester.tap(find.widgetWithText(ListTile, 'Light'));
    await tester.pumpAndSettle();
    // 다시 진입
    await tester.tap(find.text('Go Theme'));
    await tester.pumpAndSettle();
    final lightOption = find.widgetWithText(ListTile, 'Light');
    expect(
      find.descendant(of: lightOption, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });
}
