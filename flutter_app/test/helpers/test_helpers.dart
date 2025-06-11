// test/helpers/test_helpers.dart

import 'package:mockito/annotations.dart';
import 'package:campusstylistflutter/data/repository/auth_repository.dart';

// We only need to mock AuthRepository since it handles all data operations
@GenerateMocks([
  AuthRepository,
])
void main() {}