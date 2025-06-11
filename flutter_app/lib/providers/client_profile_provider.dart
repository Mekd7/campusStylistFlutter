import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/providers/api_provider.dart';
import 'package:campusstylistflutter/viewmodel/client_profile_viewmodel.dart';
import '../models/client_profile_state.dart'; // Verify this path

final clientProfileProvider = StateNotifierProvider<ClientProfileViewModel, ClientProfileState>((ref) {
  final apiService = ref.watch(apiServiceProvider); // Ensure api_serviceProvider is defined
  return ClientProfileViewModel(apiService);
});