class AuthResponse {
  final String token;
  final String role;
  final String userId;
  final bool hasCreatedProfile;

  AuthResponse({
    required this.token,
    required this.role,
    required this.userId,
    required this.hasCreatedProfile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      role: json['role'] as String,
      userId: json['userId'] as String,
      hasCreatedProfile: json['hasCreatedProfile'] as bool,
    );
  }
}