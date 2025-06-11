import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:dio/dio.dart';
import '../models/client_profile_state.dart';
import '../models/user_profile.dart';

class ClientProfileViewModel extends StateNotifier<ClientProfileState> {
  final ApiService apiService;

  ClientProfileViewModel(this.apiService) : super(ClientProfileState());

  Future<void> fetchProfile(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null, token: token);
    try {
      if (token.isEmpty) {
        print('FetchProfile: Token is empty');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication token is missing.',
          username: 'Anonymous User',
          bio: 'No bio available',
          profilePicture: 'https://via.placeholder.com/100',
        );
        return;
      }

      print('FetchProfile: Using token: $token');
      final response = await apiService.getProfile(token);
      print('FetchProfile: Response data: ${response.toJson()}');
      state = state.copyWith(
        username: response.username ?? 'Anonymous User',
        bio: response.bio ?? 'No bio available',
        profilePicture: response.profilePicture ?? 'https://via.placeholder.com/100',
        isLoading: false,
      );
    } catch (e) {
      print('FetchProfile: Error: $e');
      state = state.copyWith(
        errorMessage: e is DioException
            ? 'Network error: ${e.response?.data['message'] ?? e.message}'
            : 'Error fetching profile: ${e.toString()}',
        isLoading: false,
        username: 'Anonymous User',
        bio: 'No bio available',
        profilePicture: 'https://via.placeholder.com/100',
      );
    }
  }

  Future<void> logout(VoidCallback onLogout, VoidCallback navigateToLogin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      print('Logout: Initial state.token: ${state.token}');
      if (state.token == null || state.token!.isEmpty) {
        print('Logout: Token is empty or null');
        state = state.copyWith(
          errorMessage: 'Authentication token is missing.',
          isLoading: false,
        );
        return;
      }

      print('Logout: Calling logout with token: ${state.token}');
      await apiService.logout(state.token!);
      print('Logout: Success');
      state = ClientProfileState(); // Reset state
      print('Logout: State reset, calling onLogout and navigateToLogin');
      onLogout();
      navigateToLogin();
    } catch (e) {
      print('Logout: Error: $e');
      String errorMessage;
      if (e is DioException) {
        print('Logout: DioException response data: ${e.response?.data}');
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = (e.response?.data['message'] as String?)?.toString() ?? e.message ?? 'Unknown network error';
        } else if (e.response?.data is String) {
          errorMessage = e.response!.data.toString();
        } else if (e.response?.data is List<dynamic>) {
          errorMessage = 'Unexpected list response: ${e.response?.data}';
        } else {
          errorMessage = 'Unexpected server response: ${e.response?.data}';
        }
      } else {
        errorMessage = 'Error logging out: ${e.toString()}';
      }
      state = state.copyWith(
        errorMessage: errorMessage,
        isLoading: false,
      );
    }
  }
}

extension UserProfileExtension on UserProfile {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'bio': bio,
      'profilePicture': profilePicture,
      'hasCreatedProfile': hasCreatedProfile,
    };
  }
}