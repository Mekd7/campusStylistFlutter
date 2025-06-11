import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:campusstylistflutter/screens/create_profile_screen.dart';
import 'package:mockito/mockito.dart';

class MockCallback {
  void call() {}
}

void main() {
  testWidgets('CreateProfile Screen displays initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateProfileScreen(
            isHairdresser: true,
            token: 'mockToken',
            onProfileCreated: MockCallback(),
          ),
        ),
      ),
    );

    // Verify initial UI
    expect(find.text('Create Profile'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Upload picture'), findsOneWidget);
    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create Profile'), findsOneWidget);
  });

  testWidgets('Image picker triggers on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateProfileScreen(
            isHairdresser: true,
            token: 'mockToken',
            onProfileCreated: MockCallback(),
          ),
        ),
      ),
    );

    // Tap the CircleAvatar to trigger image picker
    await tester.tap(find.byType(CircleAvatar));
    await tester.pump();

    // Note: Image picker interaction can't be fully tested without a mock, but we can verify the tap
    expect(find.byType(CircleAvatar), findsOneWidget); // Ensure it remains
  });

  testWidgets('Text fields update state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateProfileScreen(
            isHairdresser: true,
            token: 'mockToken',
            onProfileCreated: MockCallback(),
          ),
        ),
      ),
    );

    // Enter text in name field
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.pump();

    // Enter text in bio field
    await tester.enterText(find.byType(TextField).at(1), 'A short bio');
    await tester.pump();

    // Verify text fields reflect input (indirectly via state change would require notifier access)
    expect(find.text('John Doe'), findsOneWidget); // Check if text is visible
    expect(find.text('A short bio'), findsOneWidget); // Check if text is visible
  });

  testWidgets('Create Profile button triggers loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateProfileScreen(
            isHairdresser: true,
            token: 'mockToken',
            onProfileCreated: MockCallback(),
          ),
        ),
      ),
    );

    // Enter valid input
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'A short bio');
    await tester.tap(find.byType(CircleAvatar)); // Simulate image pick (mock needed for full test)
    await tester.pump();

    // Tap create profile button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Profile'));
    await tester.pump();

    // Verify loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}