import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_model.freezed.dart';
part 'request_model.g.dart';

@freezed
class RequestModel with _$RequestModel {
  const factory RequestModel({
    required int id,
    required String title,
    required String description,
    required RequestStatus status,
    required RequestPriority priority,
    String? type,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    Map<String, dynamic>? metadata,
  }) = _RequestModel;

  factory RequestModel.fromJson(Map<String, dynamic> json) =>
      _$RequestModelFromJson(json);
}

enum RequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum RequestPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}
