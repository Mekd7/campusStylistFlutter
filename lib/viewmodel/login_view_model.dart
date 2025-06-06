import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusstylistflutter/models/auth_request.dart';
import 'package:campusstylistflutter/models/auth_response.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/viewmodel/signup_view_model.dart'; // For AuthRepository

class LoginViewModel extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  LoginViewModel({
    required this.apiService,
    required this.authRepository,
  }) {
    _loadStoredAuthData();
  }

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  String? _role;
  String? get role => _role;

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

  Future<void> _loadStoredAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  Future<void> login(void Function(String, bool, String) onSuccess) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AuthRequest(
        email: _email,
        password: _password,
        role: null, // Role not needed for login
      );
      final response = await apiService.login(request);
      _token = response.token;
      _role = response.role;
      _userId = response.userId;
      await authRepository.saveToken(
        token: response.token,
        role: response.role,
        userId: response.userId,
      );
      _isLoading = false;
      notifyListeners();
      final isHairdresser = response.role.toUpperCase() == 'HAIRDRESSER';
      onSuccess(response.token, isHairdresser, response.userId);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed: $e';
      notifyListeners();
    }
  }
}