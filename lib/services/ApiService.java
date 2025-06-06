package services;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/user_profile.dart';
import '../models/create_profile_response.dart';
import '../models/booking.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/profile_response.dart';

class ApiService {
  static const String baseUrl = 'YOUR_KTOR_BACKEND_URL'; // Replace with your Ktor backend URL, e.g., 'https://api.campusstylist.com'

  Future<AuthResponse> signUp(AuthRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to sign up: ${response.reasonPhrase}');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase}');
    }
  }

  Future<UserProfile> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user profile: ${response.reasonPhrase}');
    }
  }

  Future<CreateProfileResponse> createProfile({
    required String username,
    required String bio,
    String? profilePicturePath,
    required String token,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['username'] = username;
    request.fields['bio'] = bio;

    if (profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        profilePicturePath,
        contentType: MediaType('image', 'jpeg'), // Adjust based on file type
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return CreateProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create profile: ${response.reasonPhrase}');
    }
  }

  Future<ProfileResponse> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get profile: ${response.reasonPhrase}');
    }
  }

  Future<User> getProfileById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get profile by ID: ${response.reasonPhrase}');
    }
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.reasonPhrase}');
    }
  }

  Future<Booking> createBooking(Booking booking) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create booking: ${response.reasonPhrase}');
    }
  }

  Future<List<Booking>> getBookingsByHairstylistDate(int hairstylistId, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings?hairstylistId=$hairstylistId&date=$date'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get bookings: ${response.reasonPhrase}');
    }
  }

  Future<List<Booking>> getBookingsByUserId(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get bookings by user ID: ${response.reasonPhrase}');
    }
  }

  Future<List<Post>> getPostsByHairdresserId(String hairdresserId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$hairdresserId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get posts: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteProfile(int userId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete profile: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user by ID: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteUser(int userId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.reasonPhrase}');
    }
  }
}