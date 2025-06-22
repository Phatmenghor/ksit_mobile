enum ItemStatus {
  active,
  pending,
  completed,
  cancelled,
}

extension ItemStatusExtension on ItemStatus {
  String get name {
    switch (this) {
      case ItemStatus.active:
        return 'active';
      case ItemStatus.pending:
        return 'pending';
      case ItemStatus.completed:
        return 'completed';
      case ItemStatus.cancelled:
        return 'cancelled';
    }
  }

  static ItemStatus fromString(String value) {
    switch (value) {
      case 'active':
        return ItemStatus.active;
      case 'pending':
        return ItemStatus.pending;
      case 'completed':
        return ItemStatus.completed;
      case 'cancelled':
        return ItemStatus.cancelled;
      default:
        throw ArgumentError('Invalid ItemStatus: $value');
    }
  }
}

class HomeItemModel {
  final int id;
  final String title;
  final String description;
  final ItemStatus status;
  final String? imageUrl;
  final String? category;
  final int priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const HomeItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.imageUrl,
    this.category,
    this.priority = 0,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'imageUrl': imageUrl,
      'category': category,
      'priority': priority,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory HomeItemModel.fromJson(Map<String, dynamic> json) {
    return HomeItemModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      status: ItemStatusExtension.fromString(json['status'] as String),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  HomeItemModel copyWith({
    int? id,
    String? title,
    String? description,
    ItemStatus? status,
    String? imageUrl,
    String? category,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return HomeItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeItemModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.imageUrl == imageUrl &&
        other.category == category &&
        other.priority == priority &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        imageUrl.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'HomeItemModel(id: $id, title: $title, description: $description, status: $status, imageUrl: $imageUrl, category: $category, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
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
