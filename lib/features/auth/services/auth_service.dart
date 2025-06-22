import 'package:get/get.dart';
import 'package:ksit_mobile/core/constants/app_endpints.dart';
import 'package:ksit_mobile/core/services/api_service.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/core/utils/api_error_utils.dart';
import 'package:ksit_mobile/features/auth/models/login_request/login_request_model.dart';
import 'package:ksit_mobile/features/auth/models/login_resposne/login_response_model.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Login user with email and password
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiService.post(
        AppEndpints.loginEndpoint,
        data: request.toJson(),
      );

      // Check if response data contains the expected structure
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['data'] != null) {
          final loginResponse =
              LoginResponseModel.fromJson(responseData['data']);
          return loginResponse;
        } else {
          throw Exception('Invalid response format: missing data field');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ApiErrorUtils.throwApiError(e, 'Login failed. Please try again.');
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      LoggerUtils.info('Attempting logout');

      final response = await _apiService.post(AppEndpints.logoutEndpoint);

      if (response.statusCode == 200) {
        return response.data ?? {'message': 'Logged out successfully'};
      } else {
        throw Exception('Logout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ApiErrorUtils.throwApiError(e, 'Logout failed. Please try again.');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      LoggerUtils.info('Fetching user profile');

      final response = await _apiService.get(AppEndpints.profileEndpoint);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to fetch profile with status: ${response.statusCode}');
      }
    } catch (e) {
      ApiErrorUtils.throwApiError(
          e, 'Failed to fetch profile. Please try again.');
    }
  }
}
