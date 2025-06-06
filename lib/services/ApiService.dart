import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../models/auth_request.dart';
import '../models/login_request.dart';
import '../models/user_profile.dart';
import '../models/create_profile_response.dart';
import '../models/booking.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/profile_response.dart';

class ApiService {
  final Dio _dio;

  // Use your machine's IP for physical device access
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.7:8080',
    connectTimeout: Duration(seconds: 10), // Add timeout for debugging
    receiveTimeout: Duration(seconds: 10),
  ));

  // Validate input before sending
  void _validateInput(String field, String value) {
    if (value.isEmpty) {
      throw ArgumentError('Field "$field" cannot be empty');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      _validateInput('email', request.email);
      _validateInput('password', request.password);
      print('Login request: ${request.toJson()}');
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      print('Login response: ${response.data}');
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid input: ${e.response?.data['message'] ?? 'Email and password are required'}');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials: ${e.response?.data['message'] ?? 'Unauthorized'}');
      } else {
        throw Exception('Login failed: ${e.response?.data ?? e.message}');
      }
    }
  }

  Future<AuthResponse> signUp(AuthRequest request) async {
    try {
      _validateInput('email', request.email);
      _validateInput('password', request.password);
      _validateInput('username', request.username);
      print('SignUp request: ${request.toJson()}');
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      print('SignUp response: ${response.data}');
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('SignUp error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to sign up: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<UserProfile> getUserProfile(String token) async {
    try {
      if (token.isEmpty) throw ArgumentError('Token cannot be empty');
      final response = await _dio.get(
        '/auth/user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetUserProfile response: ${response.data}');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      print('GetUserProfile error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get user profile: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<CreateProfileResponse> createProfile({
    required String username,
    required String bio,
    String? profilePicturePath,
    required String token,
  }) async {
    try {
      _validateInput('username', username);
      _validateInput('bio', bio);
      if (token.isEmpty) throw ArgumentError('Token cannot be empty');
      final formData = FormData.fromMap({
        'username': username,
        'bio': bio,
        if (profilePicturePath != null)
          'profilePicture': await MultipartFile.fromFile(
            profilePicturePath,
            filename: profilePicturePath.split('/').last,
          ),
      });
      final response = await _dio.post(
        '/profile',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('CreateProfile response: ${response.data}');
      return CreateProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('CreateProfile error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to create profile: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // Include other methods similarly with validation and logging...
  // (Omitted for brevity, but follow the pattern above for getProfile, getProfileById, etc.)

  Future<Booking> createBooking(Booking booking) async {
    try {
      print('CreateBooking request: ${booking.toJson()}');
      final response = await _dio.post(
        '/bookings',
        data: booking.toJson(),
        options: Options(contentType: 'application/json'),
      );
      print('CreateBooking response: ${response.data}');
      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      print('CreateBooking error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to create booking: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<List<Booking>> getBookingsByHairstylistDate(int hairstylistId, String date) async {
    try {
      if (date.isEmpty) throw ArgumentError('Date cannot be empty');
      final response = await _dio.get(
        '/bookings',
        queryParameters: {'hairstylistId': hairstylistId, 'date': date},
      );
      print('GetBookingsByHairstylistDate response: ${response.data}');
      final List<dynamic> data = response.data;
      return data.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      print('GetBookingsByHairstylistDate error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get bookings: ${e.response?.data['message'] ?? e.message}');
    }
  }

// Add remaining methods (getBookingsByUserId, getPostsByHairdresserId, etc.) with similar validation and logging
}