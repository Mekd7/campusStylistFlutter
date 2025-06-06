import 'package:flutter/material.dart';
import 'package:campusstylistflutter/models/auth_request.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<void> saveToken({
    required String token,
    required String role,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('userId', userId);
  }
}

class SignUpViewModel extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  SignUpViewModel({
    required this.apiService,
    required this.authRepository,
  });

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  bool _isHairdresser = false;
  bool get isHairdresser => _isHairdresser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userId;
  String? get userId => _userId;

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setRole(bool isHairdresser) {
    _isHairdresser = isHairdresser;
    notifyListeners();
  }

  Future<void> signUp(void Function(bool, String) onSuccess) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final role = _isHairdresser ? 'HAIRDRESSER' : 'CLIENT';
      final request = AuthRequest(
        email: _email,
        password: _password,
        role: role,
      );
      final response = await apiService.signUp(request);
      _userId = response.userId;
      await authRepository.saveToken(
        token: response.token,
        role: response.role,
        userId: response.userId,
      );
      _isLoading = false;
      notifyListeners();
      onSuccess(_isHairdresser, response.token);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Signup failed: ${e.toString()}';
      notifyListeners();
    }
  }
}