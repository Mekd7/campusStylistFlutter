class User {
  final int id;
  final String? username;
  final String? bio;
  final String? profilePicture;
  final bool hasCreatedProfile;

  User({
    required this.id,
    this.username,
    this.bio,
    this.profilePicture,
    required this.hasCreatedProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
      hasCreatedProfile: json['hasCreatedProfile'] as bool? ?? false,
    );
  }
}