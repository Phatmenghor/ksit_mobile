// lib/features/attendance/controllers/attendance_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/utils/toast_utils.dart';
import 'package:ksit_mobile/core/utils/enums_utils.dart';
import 'package:ksit_mobile/core/utils/schedule_utils.dart';
import 'package:ksit_mobile/core/utils/pagination_utils.dart';
import 'package:ksit_mobile/features/attandance/models/attendance_history_filter_request_model.dart';
import 'package:ksit_mobile/features/attandance/models/attendance_models.dart';
import 'package:ksit_mobile/features/attandance/services/attendance_service.dart';

class AttendanceController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  // Observables
  final RxBool isInitialLoading = true.obs;
  final RxInt selectedAcademyYear = 0.obs;
  final Rx<Semester?> selectedSemester = Rx<Semester?>(null);
  final RxList<int> availableAcademyYears = <int>[].obs;
  final RxList<Semester> availableSemesters = <Semester>[].obs;

  // Total elements from API response
  final RxInt totalElements = 0.obs;

  // Statistics (updated for 2 statuses only)
  final RxMap<String, int> attendanceStats = <String, int>{}.obs;

  // Pagination controller
  final PagingController<int, AttendanceHistoryModel> pagingController =
      PagingController(firstPageKey: 1);

  // Default values for "show all" state
  final int _defaultYear = 0;
  final Semester? _defaultSemester = null;

  @override
  void onInit() {
    super.onInit();
    _setupPagination();
    _loadInitialData();
  }

  @override
  void onClose() {
    PaginationUtils.disposePagingController(pagingController);
    super.onClose();
  }

  void _setupPagination() {
    PaginationUtils.setupPagingController(
      controller: pagingController,
      fetchPage: _fetchAttendancePage,
    );
  }

  Future<void> _loadInitialData() async {
    try {
      isInitialLoading.value = true;

      // Generate available years and semesters
      availableAcademyYears.assignAll(ScheduleUtils.generateAcademyYears());
      availableSemesters.assignAll(ScheduleUtils.getAvailableSemesters());

      // Set default values
      selectedAcademyYear.value = 0;
      selectedSemester.value = null;

      // Load statistics
      await _loadAttendanceStats();
    } catch (e) {
      ToastUtils.showError('Failed to load attendance history');
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> _fetchAttendancePage(int pageKey) async {
    try {
      final filter = AttendanceHistoryFilterRequest(
        // academyYear:
        //     selectedAcademyYear.value != 0 ? selectedAcademyYear.value : null,
        // semester: selectedSemester.value,
        pageNo: 1,
        pageSize: 10,
      );

      final response =
          await _attendanceService.getAttendanceHistory(filter: filter);

      totalElements.value = response.totalElements;

      PaginationUtils.handlePaginationResponse(
        controller: pagingController,
        items: response.content,
        pageKey: pageKey,
        isLastPage: response.last,
      );
    } catch (e) {
      PaginationUtils.handlePaginationError(
        controller: pagingController,
        error: e,
      );
    }
  }

  Future<void> _loadAttendanceStats() async {
    try {
      final stats = await _attendanceService.getAttendanceStats();
      attendanceStats.assignAll(stats);
    } catch (e) {
      // Use default stats if API fails (only PRESENT and ABSENT)
      attendanceStats.assignAll({
        'total': 0,
        'present': 0,
        'absent': 0,
      });
    }
  }

  // Filter methods
  void setAcademyYear(int year) {
    if (selectedAcademyYear.value != year) {
      selectedAcademyYear.value = year;
      Future.delayed(Duration.zero, () {
        PaginationUtils.refreshPagingController(pagingController);
        _loadAttendanceStats();
      });
    }
  }

  void setSemester(Semester semester) {
    if (selectedSemester.value != semester) {
      selectedSemester.value = semester;
      Future.delayed(Duration.zero, () {
        PaginationUtils.refreshPagingController(pagingController);
        _loadAttendanceStats();
      });
    }
  }

  void clearSemester() {
    if (selectedSemester.value != null) {
      selectedSemester.value = null;
      Future.delayed(Duration.zero, () {
        PaginationUtils.refreshPagingController(pagingController);
        _loadAttendanceStats();
      });
    }
  }

  // Public methods for UI interactions
  Future<void> refreshAttendance() async {
    try {
      PaginationUtils.refreshPagingController(pagingController);
      await _loadAttendanceStats();
    } catch (e) {
      ToastUtils.showError('Failed to refresh attendance history');
    }
  }

  // Check if any filters are applied (not default values)
  bool get hasActiveFilters {
    return selectedAcademyYear.value != _defaultYear ||
        selectedSemester.value != _defaultSemester;
  }

  // Clear all filters to default state
  void clearAllFilters() {
    selectedAcademyYear.value = _defaultYear;
    selectedSemester.value = _defaultSemester;

    Future.delayed(Duration.zero, () {
      PaginationUtils.refreshPagingController(pagingController);
      _loadAttendanceStats();
    });

    ToastUtils.showInfo('Filters cleared');
  }

  // Helper methods for UI
  String getAttendanceStatusColor(AttendanceHistoryModel attendance) {
    return attendance.statusColor;
  }

  Color getStatusColor(String statusColor) {
    switch (statusColor) {
      case 'success':
        return const Color(0xFF4CAF50);
      case 'error':
        return const Color(0xFFF44336);
      case 'warning':
        return const Color(0xFFE4A11C);
      case 'info':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF757575);
    }
  }

  // Get attendance statistics for display
  double get attendanceRate {
    final total = attendanceStats['total'] ?? 0;
    final present = attendanceStats['present'] ?? 0;
    if (total == 0) return 0.0;
    return (present / total * 100);
  }

  int get totalAttendanceCount => totalElements.value;

  // Get status counts for stats display (updated for 2 statuses only)
  int getPresentCount() => attendanceStats['present'] ?? 0;
  int getAbsentCount() => attendanceStats['absent'] ?? 0;
}
