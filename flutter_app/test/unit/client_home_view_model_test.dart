import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:campusstylistflutter/models/post.dart';
import 'package:campusstylistflutter/models/user.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/viewmodel/client_home_view_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late ClientHomeViewModel viewModel;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    viewModel = ClientHomeViewModel(mockApiService);
  });

  group('ClientHomeViewModel', () {
    const testToken = 'test_token';
    final testPosts = [
      Post(userId: 1, pictureUrl: 'url1', description: 'desc1'),
      Post(userId: 2, pictureUrl: 'url2', description: 'desc2'),
    ];

    test('initial state has empty posts and userNames', () {
      expect(viewModel.posts, isEmpty);
      expect(viewModel.userNames, isEmpty);
    });

    test('fetchData successfully loads posts and userNames', () async {
      // Arrange
      when(mockApiService.getAllPosts(testToken)).thenAnswer((_) async => testPosts);
      when(mockApiService.getUserById('1', testToken))
          .thenAnswer((_) async => User(
        id: 1,
        username: 'User1',
        hasCreatedProfile: true,
      ));
      when(mockApiService.getUserById('2', testToken))
          .thenAnswer((_) async => User(
        id: 2,
        username: 'User2',
        hasCreatedProfile: true,
      ));

      // Act
      await viewModel.fetchData(token: testToken);

      // Assert
      expect(viewModel.posts, testPosts);
      expect(viewModel.userNames['1'], 'User1');
      expect(viewModel.userNames['2'], 'User2');
      verify(mockApiService.getAllPosts(testToken)).called(1);
      verify(mockApiService.getUserById('1', testToken)).called(1);
      verify(mockApiService.getUserById('2', testToken)).called(1);
    });

    test('fetchData handles error by loading mock data', () async {
      // Arrange
      when(mockApiService.getAllPosts(testToken)).thenThrow(Exception('Network error'));

      // Act
      await viewModel.fetchData(token: testToken);

      // Assert
      expect(viewModel.posts, isNotEmpty);
      expect(viewModel.userNames, isNotEmpty);
      expect(viewModel.posts.length, 3);
      expect(viewModel.userNames.length, 3);
    });

    test('fetchData throws exception when token is null', () async {
      // Act & Assert
      expect(() => viewModel.fetchData(), throwsException);
    });
  });
}