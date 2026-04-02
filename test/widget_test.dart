import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumni_connect/core/widgets/custom_text_field.dart';

void main() {
  testWidgets('CustomTextField simple test', (WidgetTester tester) async {
    // Build a simple CustomTextField and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            label: 'Test Label',
            hint: 'Test Hint',
          ),
        ),
      ),
    );

    // Verify that the label and hint are present.
    expect(find.text('Test Label'), findsOneWidget);
    expect(find.text('Test Hint'), findsOneWidget);
  });
}
