import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ksit_mobile/shared/models/user/user_model.dart';

part 'login_response_model.freezed.dart';
part 'login_response_model.g.dart';

@freezed
class LoginResponseModel with _$LoginResponseModel {
  const factory LoginResponseModel({
    required bool success,
    required String message,
    LoginDataModel? data,
  }) = _LoginResponseModel;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}

@freezed
class LoginDataModel with _$LoginDataModel {
  const factory LoginDataModel({
    required String token,
    required UserModel user,
  }) = _LoginDataModel;

  factory LoginDataModel.fromJson(Map<String, dynamic> json) =>
      _$LoginDataModelFromJson(json);
}
