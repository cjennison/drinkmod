// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drinkmod/main.dart';

void main() {
  testWidgets('App launches and shows welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DrinkmodApp());

    // Verify that the app launches with the welcome screen
    expect(find.text('Welcome to Drinkmod'), findsOneWidget);
    expect(find.text('Your companion for mindful drinking'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Go to Dashboard'), findsOneWidget);
  });
}
