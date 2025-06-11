import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:campusstylistflutter/models/login_request.dart';
import 'package:campusstylistflutter/models/auth_response.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/data/repository/auth_repository.dart';
import 'package:campusstylistflutter/viewmodel/login_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginViewModel viewModel;
  late MockApiService apiService;
  late MockAuthRepository authRepository;

  setUp(() {
    apiService = MockApiService();
    authRepository = MockAuthRepository();
    // Initialize SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
    viewModel = LoginViewModel(apiService: apiService, authRepository: authRepository);

    // Pre-set email and password to avoid null values
    viewModel.updateEmail('test@example.com');
    viewModel.updatePassword('password123');
  });

  test('Initial state is correct', () {
    expect(viewModel.isLoading, false);
    expect(viewModel.token, isNull);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.email, 'test@example.com');
    expect(viewModel.password, 'password123');
  });

  test('Update email and password', () {
    viewModel.updateEmail('new@example.com');
    viewModel.updatePassword('newpassword');
    expect(viewModel.email, 'new@example.com');
    expect(viewModel.password, 'newpassword');
  });

  test('Successful login', () async {
    final response = AuthResponse(
      token: 'mockToken',
      role: 'USER',
      userId: '123',
      hasCreatedProfile: true,
    );

    // Create the expected request object
    final expectedRequest = LoginRequest(
      email: 'test@example.com',
      password: 'password123',
    );

    // Mock the API call with proper type matching
    when(apiService.login(expectedRequest)).thenAnswer((_) async => response);

    // Mock the token saving with specific values
    when(authRepository.saveToken(
      token: 'mockToken',
      role: 'USER',
      userId: '123',
    )).thenAnswer((_) async => true);

    bool successCalled = false;
    await viewModel.login((token, isHairdresser, userId) {
      successCalled = true;
      expect(token, 'mockToken');
      expect(isHairdresser, false);
      expect(userId, '123');
    });

    expect(viewModel.isLoading, false);
    expect(viewModel.token, 'mockToken');
    expect(viewModel.errorMessage, isNull);
    expect(successCalled, true);
  });

  test('Login with empty fields shows error', () async {
    // Override with empty values for this test
    viewModel.updateEmail('');
    viewModel.updatePassword('');

    await viewModel.login((_, __, ___) {});

    expect(viewModel.errorMessage, 'Email and password are required');
    expect(viewModel.isLoading, false);
  });
}