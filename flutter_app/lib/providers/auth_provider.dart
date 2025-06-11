import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../models/auth_request.dart';
import '../models/login_request.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing auth data

class AuthState {
  final String? token;
  final String? role;
  final String? userId;
  final bool? hasCreatedProfile;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.token,
    this.role,
    this.userId,
    this.hasCreatedProfile,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    String? token,
    String? role,
    String? userId,
    bool? hasCreatedProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      hasCreatedProfile: hasCreatedProfile ?? this.hasCreatedProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService apiService;

  AuthNotifier(this.apiService) : super(AuthState()) {
    _loadStoredAuthData();
  }

  Future<void> _loadStoredAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final userId = prefs.getString('userId');
    if (token != null) {
      state = state.copyWith(token: token, role: role, userId: userId);
    }
  }

  Future<void> login(LoginRequest request, void Function(String, bool, String) onSuccess) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiService.login(request);
      state = state.copyWith(
        token: response.token,
        role: response.role,
        userId: response.userId,
        hasCreatedProfile: response.hasCreatedProfile,
        isLoading: false,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token ?? '');
      await prefs.setString('role', response.role ?? '');
      await prefs.setString('userId', response.userId ?? '');
      final isHairdresser = response.role?.toUpperCase() == 'HAIRDRESSER';
      onSuccess(response.token ?? '', isHairdresser ?? false, response.userId ?? '');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearAuthData() {
    state = AuthState();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('token');
      prefs.remove('role');
      prefs.remove('userId');
    });
  }
}

class AuthRepository {
  final ApiService _apiService;

  AuthRepository() : _apiService = ApiService();

  Future<AuthResponse> login(LoginRequest request) async {
    return await _apiService.login(request);
  }

  Future<AuthResponse> signUp(AuthRequest request) async {
    return await _apiService.signUp(request);
  }
}

class LoginViewModel extends StateNotifier<AuthState> {
  final ApiService apiService;

  LoginViewModel(this.apiService) : super(AuthState()) {
    _loadStoredAuthData();
  }

  Future<void> _loadStoredAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final userId = prefs.getString('userId');
    if (token != null) {
      state = state.copyWith(token: token, role: role, userId: userId);
    }
  }

  void updateEmail(String value) {
    // No state change here as email is an input, handled in UI
  }

  void updatePassword(String value) {
    // No state change here as password is an input, handled in UI
  }

  Future<void> login(LoginRequest request, void Function(String, bool, String) onSuccess) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiService.login(request);
      state = state.copyWith(
        token: response.token,
        role: response.role,
        userId: response.userId,
        hasCreatedProfile: response.hasCreatedProfile,
        isLoading: false,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token ?? '');
      await prefs.setString('role', response.role ?? '');
      await prefs.setString('userId', response.userId ?? '');
      final isHairdresser = response.role?.toUpperCase() == 'HAIRDRESSER';
      onSuccess(response.token ?? '', isHairdresser ?? false, response.userId ?? '');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class SignUpViewModel extends StateNotifier<AuthState> {
  final ApiService apiService;

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  bool _isHairdresser = false;
  bool get isHairdresser => _isHairdresser;

  SignUpViewModel(this.apiService) : super(AuthState());

  void updateEmail(String value) {
    _email = value.trim();
    state = state.copyWith(); // Trigger rebuild without changing AuthState
  }

  void updatePassword(String value) {
    _password = value.trim();
    state = state.copyWith(); // Trigger rebuild without changing AuthState
  }

  void setRole(bool isHairdresser) {
    _isHairdresser = isHairdresser;
    state = state.copyWith(); // Trigger rebuild without changing AuthState
  }

  Future<void> signUp(AuthRequest request, void Function(String, bool, String) onSuccess) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiService.signUp(request);
      state = state.copyWith(
        token: response.token,
        role: response.role,
        userId: response.userId,
        hasCreatedProfile: response.hasCreatedProfile,
        isLoading: false,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token ?? '');
      await prefs.setString('role', response.role ?? '');
      await prefs.setString('userId', response.userId ?? '');
      final isHairdresser = response.role?.toUpperCase() == 'HAIRDRESSER';
      onSuccess(response.token ?? '', isHairdresser ?? false, response.userId ?? '');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, AuthState>((ref) {
  return LoginViewModel(ref.read(apiServiceProvider));
});

final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, AuthState>((ref) {
  return SignUpViewModel(ref.read(apiServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());