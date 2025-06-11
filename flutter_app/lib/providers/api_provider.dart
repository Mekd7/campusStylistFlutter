import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/data/repository/auth_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());