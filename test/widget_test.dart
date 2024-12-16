// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Poll displays correct question', (WidgetTester tester) async {
    // Build the app with mock poll data.
    await tester.pumpWidget(const App());

    // Verify that the question "Do you like Flutter?" is displayed.
    expect(find.text('Do you like Flutter?'), findsOneWidget);
  });
  testWidgets('Vote button is visible for options', (WidgetTester tester) async {
    // Build the app with mock poll data.
    await tester.pumpWidget(const App());

    // Verify that the vote button is displayed next to each poll option.
    expect(find.widgetWithText(ElevatedButton, 'Vote'), findsNWidgets(2)); // Assuming 2 options are present.
  });
  testWidgets('Vote count updates when user votes', (WidgetTester tester) async {
    // Build the app with mock poll data.
    await tester.pumpWidget(const App());

    // Tap the 'Yes' option to cast a vote.
    await tester.tap(find.text('Yes'));
    await tester.pump();

    // Verify that the vote count has increased for the "Yes" option.
    expect(find.text('Votes: 1'), findsOneWidget);  // Assuming "Yes" has 1 vote after tapping.
  });
}

