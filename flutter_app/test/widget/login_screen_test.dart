import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:campusstylistflutter/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Login Screen displays initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LoginScreen(
            onNavigateToSignUp: () {},
            onLoginSuccess: (token, isHairdresser, userId) {},
          ),
        ),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login to CampusStylist'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text("Don't have an account? SIGN UP"), findsOneWidget);
  });

  testWidgets('Login button triggers loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LoginScreen(
            onNavigateToSignUp: () {},
            onLoginSuccess: (token, isHairdresser, userId) {},
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}