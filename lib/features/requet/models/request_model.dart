enum RequestStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

extension RequestStatusExtension on RequestStatus {
  String get name {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }

  static RequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return RequestStatus.pending;
      case 'in_progress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        throw ArgumentError('Invalid RequestStatus: $value');
    }
  }
}

enum RequestPriority {
  low,
  medium,
  high,
  urgent,
}

extension RequestPriorityExtension on RequestPriority {
  String get name {
    switch (this) {
      case RequestPriority.low:
        return 'low';
      case RequestPriority.medium:
        return 'medium';
      case RequestPriority.high:
        return 'high';
      case RequestPriority.urgent:
        return 'urgent';
    }
  }

  static RequestPriority fromString(String value) {
    switch (value) {
      case 'low':
        return RequestPriority.low;
      case 'medium':
        return RequestPriority.medium;
      case 'high':
        return RequestPriority.high;
      case 'urgent':
        return RequestPriority.urgent;
      default:
        throw ArgumentError('Invalid RequestPriority: $value');
    }
  }
}

class RequestModel {
  final int id;
  final String title;
  final String description;
  final RequestStatus status;
  final RequestPriority priority;
  final String? type;
  final String? assignedTo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final Map<String, dynamic>? metadata;

  const RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.type,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'type': type,
      'assignedTo': assignedTo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      status: RequestStatusExtension.fromString(json['status'] as String),
      priority: RequestPriorityExtension.fromString(json['priority'] as String),
      type: json['type'] as String?,
      assignedTo: json['assignedTo'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  RequestModel copyWith({
    int? id,
    String? title,
    String? description,
    RequestStatus? status,
    RequestPriority? priority,
    String? type,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    Map<String, dynamic>? metadata,
  }) {
    return RequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RequestModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.priority == priority &&
        other.type == type &&
        other.assignedTo == assignedTo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dueDate == dueDate &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        priority.hashCode ^
        type.hashCode ^
        assignedTo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        dueDate.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'RequestModel(id: $id, title: $title, description: $description, status: $status, priority: $priority, type: $type, assignedTo: $assignedTo, createdAt: $createdAt, updatedAt: $updatedAt, dueDate: $dueDate, metadata: $metadata)';
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
