// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:photo_gps_editor/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  // add failure test to check CI
  testWidgets('Counter does not increment when tapping non-existent button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Try to tap a button that doesn't exist
    expect(find.byIcon(Icons.remove), findsNothing);
    // Counter should still be 0
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Counter increments twice when tapping "+" twice', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Tap the '+' icon twice
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Counter should be 2
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Failure test to check CI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // This test is expected to fail
    expect(find.text('not-present-text'), findsOneWidget);
  });
}
