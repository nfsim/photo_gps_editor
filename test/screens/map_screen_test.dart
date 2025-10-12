import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/providers/photo_provider.dart';
import 'package:photo_gps_editor/screens/map_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapScreen Widget Tests', () {
    testWidgets('MapScreen builds without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => PhotoProvider())],
          child: const MaterialApp(home: MapScreen()),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify that the map screen is built
      expect(find.text('사진 위치 지도'), findsOneWidget);
    });

    testWidgets('MapScreen has FABs visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => PhotoProvider())],
          child: const MaterialApp(home: MapScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Test that FABs are present
      final Finder fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsNWidgets(2)); // Save GPS and Current Location FABs
    });
  });
}
