import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_item_model.freezed.dart';
part 'home_item_model.g.dart';

@freezed
class HomeItemModel with _$HomeItemModel {
  const factory HomeItemModel({
    required int id,
    required String title,
    required String description,
    required ItemStatus status,
    String? imageUrl,
    String? category,
    @Default(0) int priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _HomeItemModel;

  factory HomeItemModel.fromJson(Map<String, dynamic> json) =>
      _$HomeItemModelFromJson(json);
}

enum ItemStatus {
  @JsonValue('active')
  active,
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}
