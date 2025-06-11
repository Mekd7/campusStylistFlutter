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

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'http://172.20.10.7:8080',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

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
      if (request.role != null) _validateInput('role', request.role!);
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

  Future<String> getUserId(String token) async {
    try {
      if (token.isEmpty) throw ArgumentError('Token cannot be empty');
      final response = await _dio.get(
        '/auth/user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetUserId response: ${response.data}');
      return AuthResponse.fromJson(response.data).userId;
    } on DioException catch (e) {
      print('GetUserId error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get user ID: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<UserProfile> getProfile(String token) async {
    try {
      if (token.isEmpty) throw ArgumentError('Token cannot be empty');
      final userId = await getUserId(token);
      final response = await _dio.get(
        '/profile/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetProfile response: ${response.data}');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      print('GetProfile error: ${e.response?.data ?? e.message}');
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

  Future<Booking> createBooking(Booking booking, String token) async {
    try {
      _validateInput('token', token);
      print('CreateBooking request: ${booking.toJson()}');
      final response = await _dio.post(
        '/bookings',
        data: booking.toJson(),
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer $token'},
        ),
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
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      print('GetBookingsByHairstylistDate error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get bookings: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<List<Booking>> getBookingsByUserId(String clientId, String token) async {
    try {
      _validateInput('clientId', clientId);
      _validateInput('token', token);
      final response = await _dio.get(
        '/bookings/user/$clientId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetBookingsByUserId response: ${response.data}');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      print('GetBookingsByUserId error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get user bookings: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<List<Post>> getPostsByHairdresserId(String hairdresserId, String token) async {
    try {
      _validateInput('hairdresserId', hairdresserId);
      _validateInput('token', token);
      final response = await _dio.get(
        '/posts',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetPostsByHairdresserId response: ${response.data}');
      final List<dynamic> data = response.data as List<dynamic>;
      final posts = data.map((json) => Post.fromJson(json)).toList();
      return posts.where((post) => post.userId.toString() == hairdresserId).toList();
    } on DioException catch (e) {
      print('GetPostsByHairdresserId error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get posts: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<String> fetchHairdresserId(String token) async {
    try {
      if (token.isEmpty) throw ArgumentError('Token cannot be empty');
      final response = await _dio.get(
        '/auth/user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('FetchHairdresserId response: ${response.data}');
      return response.data['userId']?.toString() ?? '0';
    } on DioException catch (e) {
      print('FetchHairdresserId error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to fetch hairdresser ID: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<List<Post>> getAllPosts(String token) async {
    try {
      _validateInput('token', token);
      final response = await _dio.get(
        '/posts',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetAllPosts response: ${response.data}');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Post.fromJson(json)).toList();
    } on DioException catch (e) {
      print('GetAllPosts error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get posts: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<User> getUserById(String id, String token) async {
    try {
      _validateInput('id', id);
      _validateInput('token', token);
      final response = await _dio.get(
        '/profile/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('GetUserById response: ${response.data}');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      print('GetUserId error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get user: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> logout(String token) async {
    try {
      _validateInput('token', token);
      final response = await _dio.post(
        '/logout', // ✅ Updated from '/auth/logout' to '/logout'
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/json',
        ),
      );
      print('Logout response: ${response.data}');
    } on DioException catch (e) {
      print('Logout error: ${e.response?.data ?? e.message}');
      String errorMessage;
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = (e.response?.data['message'] as String?)?.toString() ?? e.message ?? 'Failed to logout';
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data.toString();
      } else {
        errorMessage = 'Unexpected server response: ${e.response?.data}';
      }
      throw Exception('Failed to logout: $errorMessage');
    }
  }


  Future<void> updateBooking(String token, String date, String time) async {
    try {
      _validateInput('token', token);
      _validateInput('date', date);
      _validateInput('time', time);
      final response = await _dio.put(
        '/bookings',
        data: {'date': date, 'time': time},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/json',
        ),
      );
      print('UpdateBooking response: ${response.data}');
    } on DioException catch (e) {
      print('UpdateBooking error: ${e.response?.data ?? e.message}');
      throw Exception('Failed to update booking: ${e.response?.data['message'] ?? e.message}');
    }
  }
}