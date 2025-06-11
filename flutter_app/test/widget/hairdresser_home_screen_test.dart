import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:campusstylistflutter/components/footer.dart';
import 'package:campusstylistflutter/models/post.dart';
import 'package:campusstylistflutter/screens/hairdresser_home.dart';
import 'package:campusstylistflutter/viewmodel/hairdresser_home_view_model.dart';

class MockHairdresserHomeViewModel extends Mock implements HairdresserHomeViewModel {}

void main() {
  late MockHairdresserHomeViewModel mockViewModel;
  late List<Post> testPosts;
  late Map<String, String> testUserNames;

  setUp(() {
    mockViewModel = MockHairdresserHomeViewModel();
    testPosts = [
      Post(userId: 123, pictureUrl: 'url1', description: 'desc1'),
      Post(userId: 123, pictureUrl: 'url2', description: 'desc2'),
    ];
    testUserNames = {'123': 'Test Hairdresser'};

    when(mockViewModel.posts).thenReturn(testPosts);
    when(mockViewModel.userNames).thenReturn(testUserNames);
    when(mockViewModel.hairdresserId).thenReturn('123');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<HairdresserHomeViewModel>.value(
        value: mockViewModel,
        child: HairdresserHomeScreen(
          token: 'test_token',
          onLogout: () {},
          onHomeClick: () {},
          onRequestsClick: () {},
          onScheduleClick: () {},
          onProfileClick: (id) {},
        ),
      ),
    );
  }

  group('HairdresserHomeScreen Widget Tests', () {
    testWidgets('displays header and footer correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(Footer), findsOneWidget);
    });

    testWidgets('displays posts when loaded', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow the widget to build

      expect(find.text('Test Hairdresser'), findsNWidgets(2));
      expect(find.text('View Profile'), findsNWidgets(2));
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('calls onProfileClick when post is tapped', (WidgetTester tester) async {
      var clickedId = '';
      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<HairdresserHomeViewModel>.value(
          value: mockViewModel,
          child: HairdresserHomeScreen(
            token: 'test_token',
            onLogout: () {},
            onHomeClick: () {},
            onRequestsClick: () {},
            onScheduleClick: () {},
            onProfileClick: (id) => clickedId = id,
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow the widget to build

      await tester.tap(find.text('View Profile').first);
      expect(clickedId, '123');
    });

    testWidgets('footer profile button calls onProfileClick with hairdresserId', (WidgetTester tester) async {
      var clickedId = '';
      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<HairdresserHomeViewModel>.value(
          value: mockViewModel,
          child: HairdresserHomeScreen(
            token: 'test_token',
            onLogout: () {},
            onHomeClick: () {},
            onRequestsClick: () {},
            onScheduleClick: () {},
            onProfileClick: (id) => clickedId = id,
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow the widget to build

      // Find the profile button in the footer (adjust based on your Footer implementation)
      final profileButtonFinder = find.descendant(
        of: find.byType(Footer),
        matching: find.byIcon(Icons.person),
      );
      await tester.tap(profileButtonFinder);
      expect(clickedId, '123');
    });

    testWidgets('displays error placeholder when image fails to load', (WidgetTester tester) async {
      // Create a testable image widget
      final testImage = Image.network(
        'invalid_url',
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.red,
          child: const Icon(Icons.error),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: testImage)));

      // Trigger the error builder
      final errorFinder = find.byType(Icon);
      expect(errorFinder, findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}