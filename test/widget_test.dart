import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumniconnect/main.dart';

void main() {
  testWidgets('AlumniConnectApp renders correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(AlumniConnectApp());

    // Verify that the app starts with the LoginPage title.
    expect(find.text('AlumniConnect'), findsOneWidget);
  });
}
