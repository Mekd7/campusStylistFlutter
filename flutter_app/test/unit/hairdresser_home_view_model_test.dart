import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:campusstylistflutter/models/post.dart';
import 'package:campusstylistflutter/models/user.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/viewmodel/hairdresser_home_view_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late HairdresserHomeViewModel viewModel;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    viewModel = HairdresserHomeViewModel(mockApiService);
  });

  group('HairdresserHomeViewModel', () {
    const testToken = 'test_token';
    final testPosts = [
      Post(userId: 123, pictureUrl: 'url1', description: 'desc1'),
      Post(userId: 123, pictureUrl: 'url2', description: 'desc2'),
    ];

    test('initial state has empty posts, userNames and null hairdresserId', () {
      expect(viewModel.posts, isEmpty);
      expect(viewModel.userNames, isEmpty);
      expect(viewModel.hairdresserId, isNull);
    });

    test('fetchData successfully loads data', () async {
      // Arrange
      when(mockApiService.fetchHairdresserId(testToken))
          .thenAnswer((_) async => '123');
      when(mockApiService.getPostsByHairdresserId('123', testToken))
          .thenAnswer((_) async => testPosts);
      when(mockApiService.getUserById('123', testToken))
          .thenAnswer((_) async => User(
        id: 123,
        username: 'Test Hairdresser',
        hasCreatedProfile: true,
      ));

      // Act
      await viewModel.fetchData(token: testToken);

      // Assert
      expect(viewModel.hairdresserId, '123');
      expect(viewModel.posts, testPosts);
      expect(viewModel.userNames['123'], 'Test Hairdresser');
      verify(mockApiService.fetchHairdresserId(testToken)).called(1);
      verify(mockApiService.getPostsByHairdresserId('123', testToken)).called(1);
      verify(mockApiService.getUserById('123', testToken)).called(1);
    });

    test('fetchData handles error by loading mock data', () async {
      // Arrange
      when(mockApiService.fetchHairdresserId(testToken))
          .thenThrow(Exception('Network error'));

      // Act
      await viewModel.fetchData(token: testToken);

      // Assert
      expect(viewModel.hairdresserId, 'current_hairdresser_id_123');
      expect(viewModel.posts, isNotEmpty);
      expect(viewModel.userNames, isNotEmpty);
      expect(viewModel.posts.length, 3);
      expect(viewModel.userNames['123'], 'Mock Stylist');
    });

    test('fetchData throws exception when token is null', () async {
      // Act & Assert
      expect(() => viewModel.fetchData(), throwsException);
    });
  });
}