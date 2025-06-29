// lib/features/home/services/home_service.dart
import 'package:get/get.dart';
import 'package:ksit_mobile/core/services/api_service.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/core/utils/api_error_utils.dart';
import 'package:ksit_mobile/shared/models/api_response_model.dart';
import '../models/schedule_models.dart';

class HomeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get my schedules with pagination
  Future<PaginatedResponse<ScheduleModel>> getMySchedules({
    int? academyYear, // Made nullable
    Semester? semester, // Made nullable
    DayOfWeek? dayOfWeek,
    Status status = Status.active,
    int pageNo = 1,
    int pageSize = 10,
  }) async {
    try {
      LoggerUtils.info('=== API CALL PARAMETERS ===');
      LoggerUtils.info(
          'academyYear: $academyYear ${academyYear == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info(
          'semester: ${semester?.name ?? "null"} ${semester == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info(
          'dayOfWeek: ${dayOfWeek?.name ?? "null"} ${dayOfWeek == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info('status: ${status.name}');
      LoggerUtils.info('pageNo: $pageNo');
      LoggerUtils.info('pageSize: $pageSize');
      LoggerUtils.info('==========================');

      // Build request data dynamically based on provided parameters
      final Map<String, dynamic> requestData = {
        'status': status.name,
        'pageNo': pageNo,
        'pageSize': pageSize,
      };

      // Only add parameters if they are not null
      if (academyYear != null) {
        requestData['academyYear'] = academyYear;
        LoggerUtils.info('✅ Added academyYear filter: $academyYear');
      } else {
        LoggerUtils.info('❌ No academyYear filter (will show all years)');
      }

      if (semester != null) {
        requestData['semester'] = semester.name;
        LoggerUtils.info('✅ Added semester filter: ${semester.name}');
      } else {
        LoggerUtils.info('❌ No semester filter (will show all semesters)');
      }

      if (dayOfWeek != null) {
        requestData['dayOfWeek'] = dayOfWeek.name;
        LoggerUtils.info('✅ Added dayOfWeek filter: ${dayOfWeek.name}');
      } else {
        LoggerUtils.info('❌ No dayOfWeek filter (will show all days)');
      }

      LoggerUtils.info('📤 Final request data: $requestData');

      final response = await _apiService.post(
        '/v1/schedules/my-schedules',
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        // Handle the new API response structure with status, message, and data
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final paginatedResponse = PaginatedResponse<ScheduleModel>.fromJson(
            responseData['data'],
            (json) => ScheduleModel.fromJson(json),
          );

          LoggerUtils.info(
              '📥 API Response: ${paginatedResponse.content.length} schedules (${paginatedResponse.totalElements} total)');
          return paginatedResponse;
        } else {
          throw Exception(
              'API Error: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      LoggerUtils.error('Error fetching schedules', e);
      ApiErrorUtils.throwApiError(
          e, 'Failed to fetch schedules. Please try again.');
    }
  }

  /// Get today's schedules
  Future<List<ScheduleModel>> getTodaySchedules({
    int? academyYear,
    Semester? semester,
  }) async {
    try {
      final currentDay = _getCurrentDayOfWeek();

      final response = await getMySchedules(
        academyYear: academyYear,
        semester: semester,
        dayOfWeek: currentDay,
        pageSize: 50, // Get more items for today
      );

      return response.content;
    } catch (e) {
      LoggerUtils.error('Error fetching today schedules', e);
      rethrow;
    }
  }

  /// Get all schedules (paginated)
  Future<PaginatedResponse<ScheduleModel>> getAllSchedules({
    int? academyYear,
    Semester? semester,
    int pageNo = 1,
    int pageSize = 10,
  }) async {
    try {
      return await getMySchedules(
        academyYear: academyYear,
        semester: semester,
        dayOfWeek: null, // No day filter for all schedules
        pageNo: pageNo,
        pageSize: pageSize,
      );
    } catch (e) {
      LoggerUtils.error('Error fetching all schedules', e);
      rethrow;
    }
  }

  /// Get available academy years (all years from 2000 to current + 10 years)
  List<int> getAvailableAcademyYears() {
    final currentYear = DateTime.now().year;
    const int startYear = 2000; // Fixed: Made const
    final endYear = currentYear + 10;

    return List.generate(
      endYear - startYear + 1,
      (index) => endYear - index,
    );
  }

  /// Get available semesters
  List<Semester> getAvailableSemesters() {
    return [Semester.semester1, Semester.semester2];
  }

  /// Get home statistics (for dashboard)
  Future<Map<String, int>> getHomeStats() async {
    try {
      // Get today's schedules count
      final todaySchedules = await getTodaySchedules();

      // Get all schedules for total count
      final allSchedules = await getAllSchedules(
        pageSize: 1, // Just get total count
      );

      return {
        'today': todaySchedules.length,
        'total': allSchedules.totalElements,
        'active': todaySchedules.where((s) => s.status == 'ACTIVE').length,
        'completed': todaySchedules.where((s) => _isCompleted(s)).length,
      };
    } catch (e) {
      LoggerUtils.error('Error fetching home stats', e);
      return {
        'today': 0,
        'total': 0,
        'active': 0,
        'completed': 0,
      };
    }
  }

  /// Check if schedule is completed (for stats)
  bool _isCompleted(ScheduleModel schedule) {
    if (schedule.startTime == null || schedule.endTime == null) return false;

    final now = DateTime.now();
    final endTime = _parseTimeString(schedule.endTime!);
    return now.isAfter(endTime) && schedule.isToday;
  }

  /// Parse time string to DateTime
  DateTime _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  /// Helper method to get current day of week
  DayOfWeek _getCurrentDayOfWeek() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  /// Get schedule by ID
  Future<ScheduleModel?> getScheduleById(int id) async {
    try {
      final response = await _apiService.get('/v1/schedules/$id');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData['data'] != null) {
          return ScheduleModel.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      LoggerUtils.error('Error fetching schedule by ID: $id', e);
      return null;
    }
  }
}
