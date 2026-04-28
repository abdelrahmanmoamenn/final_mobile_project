import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_mobile_project/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders placeholder text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('LoginScreen'), findsOneWidget);
  });
}
