// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  token: json['token'] as String,
  role: json['role'] as String,
  userId: json['userId'] as String,
  hasCreatedProfile: json['hasCreatedProfile'] as bool,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'role': instance.role,
      'userId': instance.userId,
      'hasCreatedProfile': instance.hasCreatedProfile,
    };
