import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080')); // Use machine IP for emulator/device if needed

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid input: Email and password are required');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    }
  }
}