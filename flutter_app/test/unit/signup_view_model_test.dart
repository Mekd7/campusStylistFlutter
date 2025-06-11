import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:campusstylistflutter/models/auth_request.dart';
import 'package:campusstylistflutter/models/auth_response.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/data/repository/auth_repository.dart';
import 'package:campusstylistflutter/viewmodel/signup_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpViewModel viewModel;
  late MockApiService apiService;
  late MockAuthRepository authRepository;

  setUp(() {
    apiService = MockApiService();
    authRepository = MockAuthRepository();
    // Initialize SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
    viewModel = SignUpViewModel(apiService: apiService, authRepository: authRepository);
  });

  test('Initial state is correct', () {
    expect(viewModel.isLoading, false);
    expect(viewModel.email, '');
    expect(viewModel.password, '');
    expect(viewModel.isHairdresser, false);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.userId, isNull);
  });

  test('Update email and password', () {
    viewModel.updateEmail('test@example.com');
    viewModel.updatePassword('password123');
    expect(viewModel.email, 'test@example.com');
    expect(viewModel.password, 'password123');
  });

  test('Set role updates isHairdresser', () {
    viewModel.setRole(true);
    expect(viewModel.isHairdresser, true);
    viewModel.setRole(false);
    expect(viewModel.isHairdresser, false);
  });

  test('Successful sign up', () async {
    final response = AuthResponse(
      token: 'mockToken',
      role: 'HAIRDRESSER',
      userId: '123',
      hasCreatedProfile: false,
    );
    final request = AuthRequest(
      email: 'test@example.com',
      password: 'password123',
      role: 'HAIRDRESSER',
    );

    when(apiService.signUp(request)).thenAnswer((_) async => response);
    when(authRepository.saveToken(
      token: 'mockToken',
      role: 'HAIRDRESSER',
      userId: '123',
    )).thenAnswer((_) async => true);

    viewModel.updateEmail('test@example.com');
    viewModel.updatePassword('password123');
    viewModel.setRole(true);

    bool successCalled = false;
    await viewModel.signUp((isHairdresser, token) {
      successCalled = true;
      expect(isHairdresser, true);
      expect(token, 'mockToken');
    });

    expect(viewModel.isLoading, false);
    expect(viewModel.userId, '123');
    expect(viewModel.errorMessage, isNull);
    expect(successCalled, true);
  });

  test('Sign up with empty fields shows error', () async {
    await viewModel.signUp((_, __) {});
    expect(viewModel.errorMessage, 'Email and password are required');
    expect(viewModel.isLoading, false);
  });
}