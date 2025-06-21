// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeItemModelImpl _$$HomeItemModelImplFromJson(Map<String, dynamic> json) =>
    _$HomeItemModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$ItemStatusEnumMap, json['status']),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$HomeItemModelImplToJson(_$HomeItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$ItemStatusEnumMap[instance.status]!,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'priority': instance.priority,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$ItemStatusEnumMap = {
  ItemStatus.active: 'active',
  ItemStatus.pending: 'pending',
  ItemStatus.completed: 'completed',
  ItemStatus.cancelled: 'cancelled',
};
