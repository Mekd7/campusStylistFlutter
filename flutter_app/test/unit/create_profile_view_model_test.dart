import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campusstylistflutter/models/create_profile_state.dart';
import 'package:campusstylistflutter/services/api_service.dart';
import 'package:campusstylistflutter/viewmodel/create_profile_view_model.dart';
import 'package:campusstylistflutter/models/create_profile_response.dart';

class MockApiService extends Mock implements ApiService {}
class MockXFile extends Mock implements XFile {
  @override
  final String path;

  MockXFile(this.path);
}

void main() {
  late CreateProfileViewModel viewModel;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    viewModel = CreateProfileViewModel(mockApiService);
  });

  test('Initial state is correct', () {
    expect(viewModel.state.isHairdresser, false);
    expect(viewModel.state.token, '');
    expect(viewModel.state.selectedImagePath, isNull);
    expect(viewModel.state.name, '');
    expect(viewModel.state.bio, '');
    expect(viewModel.state.errorMessage, isNull);
    expect(viewModel.state.isLoading, false);
  });

  test('setInitialData updates state correctly', () {
    viewModel.setInitialData(true, 'mockToken');

    expect(viewModel.state.isHairdresser, true);
    expect(viewModel.state.token, 'mockToken');
  });

  test('updateName and updateBio update state correctly', () {
    viewModel.updateName('John Doe');
    viewModel.updateBio('A short bio');

    expect(viewModel.state.name, 'John Doe');
    expect(viewModel.state.bio, 'A short bio');
    expect(viewModel.state.errorMessage, isNull);
  });

  // Skip the image picker helpers since we can't mock the ImagePicker
  // in the current implementation
  test('createProfile succeeds with valid data and resets state', () async {
    final successResponse = CreateProfileResponse(message: 'Profile created successfully');

    viewModel.setInitialData(true, 'mockToken');
    viewModel.updateName('John Doe');
    viewModel.updateBio('A short bio');
    // Note: We can't test with image path since we can't mock the picker

    when(mockApiService.createProfile(
      username: 'John Doe',
      bio: 'A short bio',
      profilePicturePath: null, // Image path will be null since we can't pick
      token: 'mockToken',
    )).thenAnswer((_) => Future.value(successResponse));

    bool successCallbackWasCalled = false;

    await viewModel.createProfile(() {
      successCallbackWasCalled = true;
    });

    expect(viewModel.state.isLoading, false);
    expect(viewModel.state.errorMessage, isNull);
    expect(successCallbackWasCalled, isTrue);
  });

  test('createProfile fails and sets error message when name is empty', () async {
    viewModel.setInitialData(true, 'mockToken');
    viewModel.updateBio('A short bio');

    await viewModel.createProfile(() {});

    expect(viewModel.state.isLoading, false);
    expect(viewModel.state.errorMessage, 'Name cannot be empty');
  });

  test('createProfile fails and sets error message when bio is empty', () async {
    viewModel.setInitialData(true, 'mockToken');
    viewModel.updateName('John Doe');

    await viewModel.createProfile(() {});

    expect(viewModel.state.isLoading, false);
    expect(viewModel.state.errorMessage, 'Bio cannot be empty');
  });

  test('createProfile fails and sets error message when token is missing', () async {
    viewModel.setInitialData(true, '');
    viewModel.updateName('John Doe');
    viewModel.updateBio('A short bio');

    await viewModel.createProfile(() {});

    expect(viewModel.state.isLoading, false);
    expect(viewModel.state.errorMessage, 'Authentication token is missing. Please log in again.');
  });
}