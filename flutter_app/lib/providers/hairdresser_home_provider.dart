import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../viewmodel/hairdresser_home_view_model.dart';
import 'package:campusstylistflutter/providers/api_provider.dart';

final hairdresserHomeProvider = ChangeNotifierProvider<HairdresserHomeViewModel>((ref) {
  final apiService = ref.watch(apiServiceProvider); // Assuming apiServiceProvider exists
  return HairdresserHomeViewModel(apiService);
});