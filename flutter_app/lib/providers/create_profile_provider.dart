import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/providers/api_provider.dart';
import 'package:campusstylistflutter/viewmodel/create_profile_view_model.dart';
import '../models/create_profile_state.dart';

final createProfileProvider = StateNotifierProvider<CreateProfileViewModel, CreateProfileState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CreateProfileViewModel(apiService);
});