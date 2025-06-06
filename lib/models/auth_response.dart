import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
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

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}