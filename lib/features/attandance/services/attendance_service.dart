// lib/features/attendance/services/attendance_service.dart
import 'package:get/get.dart';
import 'package:ksit_mobile/core/services/api_service.dart';
import 'package:ksit_mobile/core/utils/api_error_utils.dart';
import 'package:ksit_mobile/features/attandance/models/attendance_history_filter_request_model.dart';
import 'package:ksit_mobile/features/attandance/models/attendance_models.dart';
import 'package:ksit_mobile/shared/models/api_response_model.dart';

class AttendanceService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get attendance history with filters
  Future<PaginatedResponse<AttendanceHistoryModel>> getAttendanceHistory({
    AttendanceHistoryFilterRequest? filter,
  }) async {
    try {
      final requestData = filter?.toJson();
      final response = await _apiService.post(
        '/v1/attendance/history/token',
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final paginatedResponse =
              PaginatedResponse<AttendanceHistoryModel>.fromJson(
            responseData['data'],
            (json) => AttendanceHistoryModel.fromJson(json),
          );

          return paginatedResponse;
        } else {
          throw Exception(
              'API Error: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to fetch attendance history: ${response.statusCode}');
      }
    } catch (e) {
      ApiErrorUtils.throwApiError(
        e,
        'Failed to fetch attendance history. Please try again.',
      );
    }
  }

  /// Get attendance statistics (updated for 2 statuses only)
  Future<Map<String, int>> getAttendanceStats() async {
    try {
      // Get a large sample to calculate stats
      final response = await getAttendanceHistory(
        filter: const AttendanceHistoryFilterRequest(pageSize: 100),
      );

      final attendances = response.content;
      int present = 0;
      int absent = 0;

      for (final attendance in attendances) {
        switch (attendance.status?.toUpperCase()) {
          case 'PRESENT':
            present++;
            break;
          case 'ABSENT':
            absent++;
            break;
        }
      }

      return {
        'total': response.totalElements,
        'present': present,
        'absent': absent,
      };
    } catch (e) {
      return {
        'total': 0,
        'present': 0,
        'absent': 0,
      };
    }
  }
}
