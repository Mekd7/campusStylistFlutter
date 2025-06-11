// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:campusstylistflutter/providers/auth_provider.dart';
// import 'package:campusstylistflutter/services/api_service.dart';
// import 'package:campusstylistflutter/viewmodel/signup_view_model.dart';
// import 'package:mockito/mockito.dart';
// import 'package:campusstylistflutter/test/mocks.mocks.dart';
//
// class MockAuthRepository extends Mock implements AuthRepository {}
//
// void main() {
//   group('AuthNotifier', () {
//     late AuthNotifier notifier;
//     late MockApiService mockApiService;
//     late MockAuthRepository mockAuthRepository;
//
//     setUp(() {
//       mockApiService = MockApiService();
//       mockAuthRepository = MockAuthRepository();
//       notifier = AuthNotifier(mockApiService, mockAuthRepository);
//     });
//
//     test('updates email correctly', () {
//       notifier.updateEmail('test@example.com');
//       expect(notifier.state.email, 'test@example.com');
//     });
//
//     test('updates password correctly', () {
//       notifier.updatePassword('password123');
//       expect(notifier.state.password, 'password123');
//     });
//
//     test('login sets loading state and handles success', () async {
//       when(mockApiService.login(any)).thenAnswer((_) async => AuthResponse(
//         token: 'mock_token',
//         role: 'HAIRDRESSER',
//         userId: 'mock_user_id',
//       ));
//       when(mockAuthRepository.saveToken(any, any, any)).thenAnswer((_) async {});
//
//       final onSuccess = (String token, bool isHairdresser, String userId) {
//         expect(token, 'mock_token');
//         expect(isHairdresser, true);
//         expect(userId, 'mock_user_id');
//       };
//
//       await notifier.login(onSuccess);
//       expect(notifier.state.isLoading, false);
//       expect(notifier.state.token, 'mock_token');
//       expect(notifier.state.role, 'HAIRDRESSER');
//       expect(notifier.state.userId, 'mock_user_id');
//     });
//   });
// }