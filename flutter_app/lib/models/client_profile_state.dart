class ClientProfileState {
  final String? username;
  final String? bio;
  final String? profilePicture;
  final bool isLoading;
  final String? errorMessage;
  final String? token;

  ClientProfileState({
    this.username,
    this.bio,
    this.profilePicture,
    this.isLoading = false,
    this.errorMessage,
    this.token,
  });

  ClientProfileState copyWith({
    String? username,
    String? bio,
    String? profilePicture,
    bool? isLoading,
    String? errorMessage,
    String? token,
  }) {
    return ClientProfileState(
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      token: token ?? this.token,
    );
  }
}