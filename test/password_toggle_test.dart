import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Password toggle button test', (WidgetTester tester) async {
    // Create a test widget with password toggle functionality
    bool obscurePassword = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: obscurePassword,
              );
            },
          ),
        ),
      ),
    );

    // Verify initial state - password should be obscured
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, true);

    // Find and tap the toggle button
    final toggleButton = find.byIcon(Icons.visibility);
    expect(toggleButton, findsOneWidget);

    // Tap the toggle button
    await tester.tap(toggleButton);
    await tester.pump();

    // Verify password is now visible
    final updatedTextField = tester.widget<TextField>(find.byType(TextField));
    expect(updatedTextField.obscureText, false);

    // Find and tap the toggle button again to hide password
    final toggleButtonOff = find.byIcon(Icons.visibility_off);
    expect(toggleButtonOff, findsOneWidget);

    await tester.tap(toggleButtonOff);
    await tester.pump();

    // Verify password is obscured again
    final finalTextField = tester.widget<TextField>(find.byType(TextField));
    expect(finalTextField.obscureText, true);
  });
}