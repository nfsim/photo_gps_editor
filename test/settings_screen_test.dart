import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:photo_gps_editor/providers/font_provider.dart';
import 'package:photo_gps_editor/providers/theme_provider.dart';
import 'package:photo_gps_editor/screens/settings/settings_screen.dart';

void main() {
  testWidgets('Settings 화면 섹션/항목/셰브런/서브타이틀 UI 렌더링', (
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
    // Appearance/Theme/Font 섹션 및 항목
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Font'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    // About/License/Version/Contact 섹션 및 항목
    expect(find.text('About'), findsOneWidget);
    expect(find.text('License'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    // 서브타이틀(기본값)
  expect(find.text('System'), findsNWidgets(2));
  expect(find.text('1.0.0'), findsOneWidget);
  expect(find.text('nfsim.dev@gmail.com'), findsOneWidget);
  });
}
