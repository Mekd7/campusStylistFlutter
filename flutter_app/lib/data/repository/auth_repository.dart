import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'userId';

  String? _token;
  String? _role;
  String? _userId;

  AuthRepository() {
    _loadStoredAuthData();
  }

  Future<void> _loadStoredAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _role = prefs.getString(_roleKey);
    _userId = prefs.getString(_userIdKey);
  }

  Future<void> saveToken({required String token, String? role, String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (role != null) await prefs.setString(_roleKey, role);
    if (userId != null) await prefs.setString(_userIdKey, userId);
    _token = token;
    _role = role;
    _userId = userId;
  }

  String? get token => _token;
  String? get userId => _userId;

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    _token = null;
    _role = null;
    _userId = null;
  }
}