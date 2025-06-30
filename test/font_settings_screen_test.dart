import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:photo_gps_editor/providers/font_provider.dart';
import 'package:photo_gps_editor/screens/settings/font_settings_screen.dart';

void main() {
  testWidgets('폰트 드롭다운 및 미리보기 동작', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FontProvider(),
        child: const MaterialApp(home: FontSettingsScreen()),
      ),
    );

    // 기본 미리보기 텍스트 존재
    expect(find.text('가나다 ABCD 1234'), findsNWidgets(3));
    // 드롭다운 존재
    expect(find.byType(DropdownButton<String?>), findsOneWidget);

    // 드롭다운 열기
    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();

    // 시스템 기본, Noto Sans, Noto Sans KR 등 폰트 항목 존재
    expect(find.text('시스템 기본'), findsWidgets);
    expect(find.text('Noto Sans'), findsOneWidget);
    expect(find.text('Noto Sans KR'), findsOneWidget);

    // Noto Sans KR 선택
    await tester.tap(find.text('Noto Sans KR').last);
    await tester.pumpAndSettle();
    // 미리보기 텍스트가 3개 존재(폰트 적용 확인은 golden test 필요)
    expect(find.text('가나다 ABCD 1234'), findsNWidgets(3));
  });
}
