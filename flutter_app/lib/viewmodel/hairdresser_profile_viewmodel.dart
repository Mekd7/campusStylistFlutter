import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../models/post.dart';
import '../data/repository/auth_repository.dart';
import '../providers/api_provider.dart';

const String baseUrl = 'http://172.20.10.7:8080'; // Replace with actual API base URL

class HairDresserProfileViewModel extends ChangeNotifier {
  User? _user;
  List<Post> _posts = [];
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  List<Post> get posts => _posts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  final AuthRepository _authRepository;

  HairDresserProfileViewModel(this._authRepository);

  Future<void> fetchProfile(String token, String hairdresserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _user = User(
        id: int.tryParse(hairdresserId) ?? 0,
        username: 'Ashley Gram',
        profilePicture: 'https://i.pinimg.com/736x/8b/16/7a/8b167af653c2399dd93b952a48740620.jpg',
        hasCreatedProfile: true,
        bio: 'Hair is my passion\nLocated at AAiT, dorm room 306\nBook Now!!!',
      );

      _posts = _generateDummyPosts(hairdresserId);
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- THIS METHOD IS UPDATED WITH YOUR CHOSEN IMAGE ---
  List<Post> _generateDummyPosts(String hairdresserId) {
    return List.generate(6, (index) {
      // All posts will now use the image you provided.
      const imageUrl = 'https://cdn.shopify.com/s/files/1/0641/2831/9725/files/what_are_bohemian_braids.webp?v=1747219302';
      return Post(
        id: index + 1,
        userId: int.tryParse(hairdresserId) ?? 0,
        description: 'This is a beautiful hairstyle, post number ${index + 1}.',
        pictureUrl: imageUrl,
      );
    });
  }

  // --- YOUR ORIGINAL METHODS ARE KEPT BELOW ---
  Future<void> logout(VoidCallback onSuccess) async {
    // ... your existing code ...
  }

  Future<void> deleteAccount(String token, VoidCallback onSuccess) async {
    // ... your existing code ...
  }

  void _handleHttpError(int statusCode) {
    _errorMessage = switch (statusCode) {
      401 => 'Session expired. Please log in again.',
      403 => 'You can only access your own profile.',
      _ => 'Failed to fetch profile: HTTP $statusCode',
    };
  }

  void _handleLogoutError(int statusCode) {
    _errorMessage = switch (statusCode) {
      401 => 'Invalid token. Please log in again.',
      _ => 'Logout failed: HTTP $statusCode',
    };
  }
}

// The Riverpod provider that creates the ViewModel
final hairDresserProfileProvider =
ChangeNotifierProvider.autoDispose<HairDresserProfileViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return HairDresserProfileViewModel(authRepository);
});