class CreateProfileState {
  final String name;
  final String bio;
  final bool isHairdresser;
  final String? errorMessage;
  final bool isLoading;
  final String? selectedImagePath;
  final String token;

  CreateProfileState({
    this.name = '',
    this.bio = '',
    this.isHairdresser = false,
    this.errorMessage,
    this.isLoading = false,
    this.selectedImagePath,
    this.token = '',
  });

  CreateProfileState copyWith({
    String? name,
    String? bio,
    bool? isHairdresser,
    String? errorMessage,
    bool? isLoading,
    String? selectedImagePath,
    String? token,
  }) {
    return CreateProfileState(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      isHairdresser: isHairdresser ?? this.isHairdresser,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      selectedImagePath: selectedImagePath,
      token: token ?? this.token,
    );
  }
}