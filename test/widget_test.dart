import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:password_app/main.dart'; 

void main() {
  testWidgets('App UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PasswordManagerApp());

    // Basic test to ensure the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}