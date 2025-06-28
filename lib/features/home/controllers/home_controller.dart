// lib/features/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/core/utils/toast_utils.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import '../models/schedule_models.dart';
import '../screens/home_screen.dart';

class ScheduleController extends GetxController {
  final HomeService _homeService = Get.find<HomeService>();

  // Observables
  final RxBool isInitialLoading = true.obs;
  final Rx<FilterType> selectedFilterType = FilterType.all.obs;
  final RxInt selectedAcademyYear = 0.obs; // No default selection
  final Rx<Semester?> selectedSemester =
      Rx<Semester?>(null); // No default selection
  final RxList<int> availableAcademyYears = <int>[].obs;
  final RxList<Semester> availableSemesters = <Semester>[].obs;

  // Today's schedules
  final RxList<ScheduleModel> todaySchedules = <ScheduleModel>[].obs;
  final RxBool isTodayLoading = false.obs;

  // All schedules pagination
  final PagingController<int, ScheduleModel> allSchedulesPagingController =
      PagingController(firstPageKey: 1);

  // Default values for "show all" state
  final int _defaultYear = 0; // No default year
  final Semester? _defaultSemester = null; // No default semester

  @override
  void onInit() {
    super.onInit();
    _setupPagination();
    _loadInitialData();
  }

  @override
  void onClose() {
    allSchedulesPagingController.dispose();
    super.onClose();
  }

  void _setupPagination() {
    allSchedulesPagingController.addPageRequestListener((pageKey) {
      _fetchAllSchedulesPage(pageKey);
    });
  }

  Future<void> _loadInitialData() async {
    try {
      isInitialLoading.value = true;

      // Load available years and semesters
      availableAcademyYears.assignAll(_homeService.getAvailableAcademyYears());
      availableSemesters.assignAll(_homeService.getAvailableSemesters());

      // Set default filter to show all schedules without year/semester filtering
      selectedFilterType.value = FilterType.all;
      selectedAcademyYear.value = 0; // No default selection
      selectedSemester.value = null; // No default selection

      // Load initial data based on current filter
      await _refreshCurrentFilter();

      LoggerUtils.info('Initial schedule data loaded successfully');
    } catch (e) {
      LoggerUtils.error('Error loading initial schedule data', e);
      ToastUtils.showError('Failed to load schedules');
    } finally {
      isInitialLoading.value = false;
    }
  }

  void setFilterType(FilterType filterType) {
    if (selectedFilterType.value != filterType) {
      selectedFilterType.value = filterType;
      _refreshCurrentFilter();
      LoggerUtils.info('Filter type changed to: ${filterType.name}');
    }
  }

  void setAcademyYear(int year) {
    if (selectedAcademyYear.value != year) {
      selectedAcademyYear.value = year;
      _refreshCurrentFilter();
      LoggerUtils.info('Academy year changed to: $year');
    }
  }

  void setSemester(Semester semester) {
    if (selectedSemester.value != semester) {
      selectedSemester.value = semester;
      _refreshCurrentFilter();
      LoggerUtils.info('Semester changed to: ${semester.displayName}');
    }
  }

  void clearSemester() {
    selectedSemester.value = null;
    _refreshCurrentFilter();
    LoggerUtils.info('Semester cleared');
  }

  Future<void> _refreshCurrentFilter() async {
    if (selectedFilterType.value == FilterType.today) {
      await _loadTodaySchedules();
    } else {
      allSchedulesPagingController.refresh();
    }
  }

  Future<void> _loadTodaySchedules() async {
    try {
      isTodayLoading.value = true;

      // Get current day of week
      final currentDay = _getCurrentDayOfWeek();

      // Only apply filters if they are selected (not default/null values)
      final response = await _homeService.getMySchedules(
        academyYear: selectedAcademyYear.value != 0
            ? selectedAcademyYear.value
            : DateTime.now().year,
        semester: selectedSemester.value ?? Semester.semester1,
        dayOfWeek: currentDay,
      );

      todaySchedules.assignAll(response.content);

      LoggerUtils.info('Today schedules loaded: ${response.content.length}');
    } catch (e) {
      LoggerUtils.error('Error loading today schedules', e);
      ToastUtils.showError('Failed to load today\'s schedules');
    } finally {
      isTodayLoading.value = false;
    }
  }

  Future<void> _fetchAllSchedulesPage(int pageKey) async {
    try {
      // Only apply filters if they are selected (not default/null values)
      final response = await _homeService.getMySchedules(
        academyYear: selectedAcademyYear.value != 0
            ? selectedAcademyYear.value
            : DateTime.now().year,
        semester: selectedSemester.value ?? Semester.semester1,
        // dayOfWeek is null for all schedules
        pageNo: pageKey,
        pageSize: 10,
      );

      final isLastPage = response.last;
      if (isLastPage) {
        allSchedulesPagingController.appendLastPage(response.content);
      } else {
        final nextPageKey = pageKey + 1;
        allSchedulesPagingController.appendPage(response.content, nextPageKey);
      }

      LoggerUtils.info(
          'All schedules page $pageKey loaded with ${response.content.length} items');
    } catch (e) {
      LoggerUtils.error('Error fetching all schedules page $pageKey', e);
      allSchedulesPagingController.error = e.toString();
    }
  }

  // Public methods for UI interactions
  Future<void> refreshSchedules() async {
    try {
      await _refreshCurrentFilter();
      LoggerUtils.info('Schedules refreshed successfully');
    } catch (e) {
      LoggerUtils.error('Error refreshing schedules', e);
      ToastUtils.showError('Failed to refresh schedules');
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

    // Refresh current filter view
    _refreshCurrentFilter();

    ToastUtils.showInfo('Filters cleared');
    LoggerUtils.info('All filters cleared to default values');
  }

  void onScheduleTap(ScheduleModel schedule) {
    LoggerUtils.info('Schedule tapped: ${schedule.id}');
    // TODO: Navigate to detail screen
    // Get.toNamed('/schedule-detail', arguments: schedule);
  }

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

  // Helper methods for UI
  String getScheduleStatusText(ScheduleModel schedule) {
    final now = DateTime.now();
    final scheduleTime = _parseTimeString(schedule.startTime);
    final endTime = _parseTimeString(schedule.endTime);

    if (schedule.isToday) {
      if (now.isBefore(scheduleTime)) {
        return 'Upcoming';
      } else if (now.isAfter(endTime)) {
        return 'Completed';
      } else {
        return 'Ongoing';
      }
    }
    return 'Scheduled';
  }

  DateTime _parseTimeString(String? timeString) {
    if (timeString == null) return DateTime.now();
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

  Color getScheduleStatusColor(ScheduleModel schedule) {
    final status = getScheduleStatusText(schedule);
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
