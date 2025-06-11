import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:campusstylistflutter/screens/signup_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('SignUp Screen displays initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(
            onNavigateToLogin: () {},
            onSignupSuccess: (role, isHairdresser, userId, token) {},
          ),
        ),
      ),
    );

    // Verify welcome text
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Create an account to join CampusStylist'), findsOneWidget);

    // Verify email and password fields
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify role buttons
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Hairdresser'), findsOneWidget);

    // Verify sign-up button is disabled initially
    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    expect(tester.widget<ElevatedButton>(signUpButton).onPressed, isNull);
  });

  testWidgets('SignUp button enables with valid input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(
            onNavigateToLogin: () {},
            onSignupSuccess: (role, isHairdresser, userId, token) {},
          ),
        ),
      ),
    );

    // Enter valid email and password
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pump();

    // Verify sign-up button is enabled
    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    expect(tester.widget<ElevatedButton>(signUpButton).onPressed, isNotNull);
  });

  testWidgets('SignUp button triggers loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(
            onNavigateToLogin: () {},
            onSignupSuccess: (role, isHairdresser, userId, token) {},
          ),
        ),
      ),
    );

    // Enter valid input
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pump();

    // Tap sign-up button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Role selection updates button color', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(
            onNavigateToLogin: () {},
            onSignupSuccess: (role, isHairdresser, userId, token) {},
          ),
        ),
      ),
    );

    // Initially, Client button should be pink
    final clientButton = find.widgetWithText(ElevatedButton, 'Client');
    expect(
      (tester.widget<ElevatedButton>(clientButton).style?.backgroundColor as MaterialStateProperty).resolve({}),
      const Color(0xFFE0136C),
    );
    expect(
      (tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Hairdresser')).style?.backgroundColor as MaterialStateProperty).resolve({}),
      const Color(0xFFA7A3A3),
    );

    // Tap Hairdresser button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hairdresser'));
    await tester.pump();

    // Verify Hairdresser button is now pink
    expect(
      (tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Hairdresser')).style?.backgroundColor as MaterialStateProperty).resolve({}),
      const Color(0xFFE0136C),
    );
    expect(
      (tester.widget<ElevatedButton>(clientButton).style?.backgroundColor as MaterialStateProperty).resolve({}),
      const Color(0xFFA7A3A3),
    );
  });
}