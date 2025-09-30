import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:photo_gps_editor/providers/font_provider.dart';
import 'package:photo_gps_editor/providers/theme_provider.dart';
import 'package:photo_gps_editor/screens/settings/settings_screen.dart';

void main() {
  testWidgets('Theme 선택 다이얼로그에서 현재 선택된 theme에 체크(v) 표시', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FontProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    // Theme ListTile을 탭
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    // 다이얼로그 내 theme 목록 존재
    expect(find.widgetWithText(SimpleDialogOption, 'System'), findsOneWidget);
    expect(find.widgetWithText(SimpleDialogOption, 'Light'), findsOneWidget);
    expect(find.widgetWithText(SimpleDialogOption, 'Dark'), findsOneWidget);
    // 기본값 System에 체크(v) 아이콘 존재
    final systemOption = find.widgetWithText(SimpleDialogOption, 'System');
    expect(
      find.descendant(of: systemOption, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    // Light 선택 시 체크가 이동
    await tester.tap(find.widgetWithText(SimpleDialogOption, 'Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    final lightOption = find.widgetWithText(SimpleDialogOption, 'Light');
    expect(
      find.descendant(of: lightOption, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });
}
