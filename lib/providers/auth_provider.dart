import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';

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

  AuthNotifier(this.apiService) : super(AuthState());

  Future<void> login(String email, String password, void Function(String, bool, String) onSuccess) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiService.login(email, password);
      state = state.copyWith(
        token: response.token,
        role: response.role,
        userId: response.userId,
        hasCreatedProfile: response.hasCreatedProfile,
        isLoading: false,
      );
      final isHairdresser = response.role.toUpperCase() == 'HAIRDRESSER';
      onSuccess(response.token, isHairdresser, response.userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearAuthData() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiService());
});