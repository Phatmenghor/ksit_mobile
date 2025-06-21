// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HomeItemModel _$HomeItemModelFromJson(Map<String, dynamic> json) {
  return _HomeItemModel.fromJson(json);
}

/// @nodoc
mixin _$HomeItemModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ItemStatus get status => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this HomeItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeItemModelCopyWith<HomeItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeItemModelCopyWith<$Res> {
  factory $HomeItemModelCopyWith(
          HomeItemModel value, $Res Function(HomeItemModel) then) =
      _$HomeItemModelCopyWithImpl<$Res, HomeItemModel>;
  @useResult
  $Res call(
      {int id,
      String title,
      String description,
      ItemStatus status,
      String? imageUrl,
      String? category,
      int priority,
      DateTime? createdAt,
      DateTime? updatedAt,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$HomeItemModelCopyWithImpl<$Res, $Val extends HomeItemModel>
    implements $HomeItemModelCopyWith<$Res> {
  _$HomeItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
    Object? imageUrl = freezed,
    Object? category = freezed,
    Object? priority = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ItemStatus,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeItemModelImplCopyWith<$Res>
    implements $HomeItemModelCopyWith<$Res> {
  factory _$$HomeItemModelImplCopyWith(
          _$HomeItemModelImpl value, $Res Function(_$HomeItemModelImpl) then) =
      __$$HomeItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String description,
      ItemStatus status,
      String? imageUrl,
      String? category,
      int priority,
      DateTime? createdAt,
      DateTime? updatedAt,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$HomeItemModelImplCopyWithImpl<$Res>
    extends _$HomeItemModelCopyWithImpl<$Res, _$HomeItemModelImpl>
    implements _$$HomeItemModelImplCopyWith<$Res> {
  __$$HomeItemModelImplCopyWithImpl(
      _$HomeItemModelImpl _value, $Res Function(_$HomeItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
    Object? imageUrl = freezed,
    Object? category = freezed,
    Object? priority = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$HomeItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ItemStatus,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeItemModelImpl implements _HomeItemModel {
  const _$HomeItemModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.status,
      this.imageUrl,
      this.category,
      this.priority = 0,
      this.createdAt,
      this.updatedAt,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$HomeItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeItemModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  final ItemStatus status;
  @override
  final String? imageUrl;
  @override
  final String? category;
  @override
  @JsonKey()
  final int priority;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'HomeItemModel(id: $id, title: $title, description: $description, status: $status, imageUrl: $imageUrl, category: $category, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      status,
      imageUrl,
      category,
      priority,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of HomeItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeItemModelImplCopyWith<_$HomeItemModelImpl> get copyWith =>
      __$$HomeItemModelImplCopyWithImpl<_$HomeItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeItemModelImplToJson(
      this,
    );
  }
}

abstract class _HomeItemModel implements HomeItemModel {
  const factory _HomeItemModel(
      {required final int id,
      required final String title,
      required final String description,
      required final ItemStatus status,
      final String? imageUrl,
      final String? category,
      final int priority,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final Map<String, dynamic>? metadata}) = _$HomeItemModelImpl;

  factory _HomeItemModel.fromJson(Map<String, dynamic> json) =
      _$HomeItemModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  ItemStatus get status;
  @override
  String? get imageUrl;
  @override
  String? get category;
  @override
  int get priority;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of HomeItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeItemModelImplCopyWith<_$HomeItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
