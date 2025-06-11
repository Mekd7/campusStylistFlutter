import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../models/create_profile_state.dart';
import '../services/api_service.dart';

class CreateProfileViewModel extends StateNotifier<CreateProfileState> {
  final ApiService apiService;
  final ImagePicker _imagePicker = ImagePicker();

  CreateProfileViewModel(this.apiService) : super(CreateProfileState());

  void setInitialData(bool isHairdresser, String token) {
    state = state.copyWith(
      isHairdresser: isHairdresser,
      token: token,
      selectedImagePath: null,
      name: '',
      bio: '',
      errorMessage: null,
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value, errorMessage: null);
  }

  void updateBio(String value) {
    state = state.copyWith(bio: value, errorMessage: null);
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        state = state.copyWith(selectedImagePath: pickedFile.path, errorMessage: null);
      } else {
        state = state.copyWith(errorMessage: 'No image selected');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error picking image: ${e.toString()}');
    }
  }

  Future<void> createProfile(void Function() onSuccess) async {
    if (state.name.isEmpty) {
      state = state.copyWith(errorMessage: 'Name cannot be empty');
      return;
    }
    if (state.bio.isEmpty) {
      state = state.copyWith(errorMessage: 'Bio cannot be empty');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (state.token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication token is missing. Please log in again.',
        );
        return;
      }

      final response = await apiService.createProfile(
        username: state.name,
        bio: state.bio,
        profilePicturePath: state.selectedImagePath,
        token: state.token,
      );

      if (response.message == 'Profile created successfully') {
        state = CreateProfileState(
          isHairdresser: state.isHairdresser,
          token: state.token,
        ); // Reset state, keep isHairdresser and token
        onSuccess();
      } else {
        state = state.copyWith(isLoading: false, errorMessage: response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is DioException
            ? 'Network error: ${e.response?.data['message'] ?? e.message}'
            : 'Error creating profile: ${e.toString()}',
      );
    }
  }
}