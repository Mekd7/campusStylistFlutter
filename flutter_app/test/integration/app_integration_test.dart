// test/integration/app_integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// FIXED: This import will now work after 'flutter pub get'
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import 'package:campusstylistflutter/routes/app_router.dart';
// FIXED: Import the file where your provider is defined
import 'package:campusstylistflutter/data/repository/auth_repository.dart';
import 'package:campusstylistflutter/models/post.dart';
import 'package:campusstylistflutter/components/footer.dart';

// FIXED: Import the generated '.mocks.dart' file, not the source file
import '../helpers/test_helpers.mocks.dart';

void main() {
  // FIXED: This will be recognized now
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // FIXED: This class is defined in the imported .mocks.dart file
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  testWidgets('Hairdresser sign up flow: Login -> SignUp -> Create Profile -> Home',
          (WidgetTester tester) async {
        // (Your when(...) mock definitions remain the same here)
        when(mockAuthRepository.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          role: 'Hairdresser',
        )).thenAnswer((_) async => {
          'token': 'mock-jwt-token',
          'userId': '123',
          'isHairdresser': true,
        });
        when(mockAuthRepository.createProfile(
          token: 'mock-jwt-token',
          name: 'Jane Doe Stylist',
          bio: 'Expert in modern hairstyles.',
          isHairdresser: true,
          imageFile: anyNamed('imageFile'),
        )).thenAnswer((_) async => {});
        when(mockAuthRepository.fetchPosts('mock-jwt-token')).thenAnswer((_) async => [
          Post(userId: 123, pictureUrl: 'https://fakeurl.com/image.png', description: 'Fresh look!'),
        ]);
        when(mockAuthRepository.getUserDetailsForPosts(any, any))
            .thenAnswer((_) async => {'123': 'Jane Doe Stylist'});
        when(mockAuthRepository.userId).thenReturn('123');

        // Pump the app
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // FIXED: This provider is now recognized from the import
              authRepositoryProvider.overrideWithValue(mockAuthRepository),
            ],
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // The rest of your test logic remains the same...
        expect(find.text('Welcome back'), findsOneWidget);
        await tester.tap(find.text("Don't have an account? SIGN UP"));
        await tester.pumpAndSettle();

        expect(find.text('Welcome!'), findsOneWidget);
        await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Hairdresser'));
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Create Profile'), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextField, 'Your Name'), 'Jane Doe Stylist');
        await tester.enterText(find.widgetWithText(TextField, 'Bio'), 'Expert in modern hairstyles.');
        await tester.tap(find.byType(CircleAvatar));
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create Profile'));
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.byType(Footer), findsOneWidget);

        expect(find.text('Jane Doe Stylist'), findsOneWidget);
        expect(find.text('Fresh look!'), findsOneWidget);
      });
}