// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseModelImpl _$$LoginResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginResponseModelImpl(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      fullToken: json['fullToken'] as String,
    );

Map<String, dynamic> _$$LoginResponseModelImplToJson(
        _$LoginResponseModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'roles': instance.roles,
      'fullToken': instance.fullToken,
    };
