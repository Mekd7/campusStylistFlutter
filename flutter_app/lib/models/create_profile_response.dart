class CreateProfileResponse {
  final String message;

  CreateProfileResponse({
    required this.message,
  });

  factory CreateProfileResponse.fromJson(Map<String, dynamic> json) {
    return CreateProfileResponse(
      message: json['message'] as String? ?? 'Profile created successfully',
    );
  }
}