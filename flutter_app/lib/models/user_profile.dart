class UserProfile {
  final int id;
  final String email;
  final String? username;
  final String? bio;
  final String? profilePicture;
  final bool hasCreatedProfile;
  final String role;

  UserProfile({
    required this.id,
    required this.email,
    this.username,
    this.bio,
    this.profilePicture,
    required this.hasCreatedProfile,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
      hasCreatedProfile: json['hasCreatedProfile'] as bool? ?? false,
      role: json['role'] is String
          ? json['role']
          : json['role'] != null
          ? json['role']['name'] as String? ?? ''
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'bio': bio,
      'profilePicture': profilePicture,
      'hasCreatedProfile': hasCreatedProfile,
      'role': role,
    };
  }
}