// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'role': instance.role,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'phone': instance.phone,
      'gender': instance.gender,
      'metadata': instance.metadata,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
