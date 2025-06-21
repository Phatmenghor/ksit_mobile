// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RequestModelImpl _$$RequestModelImplFromJson(Map<String, dynamic> json) =>
    _$RequestModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      priority: $enumDecode(_$RequestPriorityEnumMap, json['priority']),
      type: json['type'] as String?,
      assignedTo: json['assignedTo'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RequestModelImplToJson(_$RequestModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'priority': _$RequestPriorityEnumMap[instance.priority]!,
      'type': instance.type,
      'assignedTo': instance.assignedTo,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.inProgress: 'in_progress',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
};

const _$RequestPriorityEnumMap = {
  RequestPriority.low: 'low',
  RequestPriority.medium: 'medium',
  RequestPriority.high: 'high',
  RequestPriority.urgent: 'urgent',
};
