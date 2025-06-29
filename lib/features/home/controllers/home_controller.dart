// lib/features/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/core/utils/toast_utils.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import '../models/schedule_models.dart';
import '../screens/home_screen.dart';

class HomeController extends GetxController {
  final HomeService _homeService = Get.find<HomeService>();

  // Observables
  final RxBool isInitialLoading = true.obs;
  final Rx<FilterType> selectedFilterType =
      FilterType.today.obs; // Default to today
  final RxInt selectedAcademyYear = 0.obs; // 0 = no filter (like undefined)
  final Rx<Semester?> selectedSemester =
      Rx<Semester?>(null); // null = no filter (like undefined)
  final RxList<int> availableAcademyYears = <int>[].obs;
  final RxList<Semester> availableSemesters = <Semester>[].obs;

  // Observables for total counts from API
  final RxInt todayTotalElements = 0.obs;
  final RxInt allTotalElements = 0.obs;

  // Today's schedules with pagination
  final PagingController<int, ScheduleModel> todaySchedulesPagingController =
      PagingController(firstPageKey: 1);

  // All schedules pagination
  final PagingController<int, ScheduleModel> allSchedulesPagingController =
      PagingController(firstPageKey: 1);

  // Default values for "show all" state
  final int _defaultYear = 0; // 0 = no filter
  final Semester? _defaultSemester = null; // null = no filter

  @override
  void onInit() {
    super.onInit();
    _setupPagination();
    _loadInitialData();
  }

  @override
  void onClose() {
    todaySchedulesPagingController.dispose();
    allSchedulesPagingController.dispose();
    super.onClose();
  }

  void _setupPagination() {
    // Setup today schedules pagination
    todaySchedulesPagingController.addPageRequestListener((pageKey) {
      _fetchTodaySchedulesPage(pageKey);
    });

    // Setup all schedules pagination
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

      // Set default filter to show today's schedules
      selectedFilterType.value = FilterType.today;

      // NO DEFAULT FILTERS - Let user choose explicitly
      selectedAcademyYear.value = 0; // 0 = no filter (like undefined)
      selectedSemester.value = null; // null = no filter (like undefined)

      LoggerUtils.info('=== INITIAL STATE ===');
      LoggerUtils.info(
          'App starts with NO FILTERS (like undefined in Next.js)');
      LoggerUtils.info(
          'selectedAcademyYear: ${selectedAcademyYear.value} (0 = no filter)');
      LoggerUtils.info(
          'selectedSemester: ${selectedSemester.value} (null = no filter)');
      LoggerUtils.info('selectedFilterType: ${selectedFilterType.value.name}');
      LoggerUtils.info('=====================');
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

      // Immediately trigger refresh for the selected tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (filterType == FilterType.today) {
          // Check if today controller needs to load data
          if (todaySchedulesPagingController.itemList == null) {
            // Force the first page request for today tab
            _fetchTodaySchedulesPage(1);
            LoggerUtils.info('Today tab - triggering first load');
          } else {
            todaySchedulesPagingController.refresh();
            LoggerUtils.info('Today tab - refreshing existing data');
          }
        } else {
          // Check if all schedules controller needs to load data
          if (allSchedulesPagingController.itemList == null) {
            // Force the first page request for all schedules tab
            _fetchAllSchedulesPage(1);
            LoggerUtils.info('All schedules tab - triggering first load');
          } else {
            allSchedulesPagingController.refresh();
            LoggerUtils.info('All schedules tab - refreshing existing data');
          }
        }
      });

      LoggerUtils.info('Filter type changed to: ${filterType.name}');
    }
  }

  void setAcademyYear(int year) {
    if (selectedAcademyYear.value != year) {
      final oldYear = selectedAcademyYear.value;
      selectedAcademyYear.value = year;

      LoggerUtils.info('=== ACADEMY YEAR FILTER CHANGED ===');
      LoggerUtils.info('From: $oldYear ${oldYear == 0 ? "(no filter)" : ""}');
      LoggerUtils.info('To: $year ${year == 0 ? "(no filter)" : ""}');
      LoggerUtils.info('===================================');

      // Always refresh the currently active tab
      Future.delayed(Duration.zero, () {
        if (selectedFilterType.value == FilterType.today) {
          todaySchedulesPagingController.refresh();
        } else {
          allSchedulesPagingController.refresh();
        }
      });
    }
  }

  void setSemester(Semester semester) {
    if (selectedSemester.value != semester) {
      final oldSemester = selectedSemester.value;
      selectedSemester.value = semester;

      LoggerUtils.info('=== SEMESTER FILTER CHANGED ===');
      LoggerUtils.info(
          'From: ${oldSemester?.name ?? "null"} ${oldSemester == null ? "(no filter)" : ""}');
      LoggerUtils.info('To: ${semester.name}');
      LoggerUtils.info('===============================');

      // Always refresh the currently active tab
      Future.delayed(Duration.zero, () {
        if (selectedFilterType.value == FilterType.today) {
          todaySchedulesPagingController.refresh();
        } else {
          allSchedulesPagingController.refresh();
        }
      });
    }
  }

  void clearSemester() {
    if (selectedSemester.value != null) {
      final oldSemester = selectedSemester.value;
      selectedSemester.value = null;

      LoggerUtils.info('=== SEMESTER FILTER CLEARED ===');
      LoggerUtils.info('From: ${oldSemester?.name}');
      LoggerUtils.info('To: null (no filter)');
      LoggerUtils.info('===============================');

      // Always refresh the currently active tab
      Future.delayed(Duration.zero, () {
        if (selectedFilterType.value == FilterType.today) {
          todaySchedulesPagingController.refresh();
        } else {
          allSchedulesPagingController.refresh();
        }
      });
    }
  }

  Future<void> _fetchTodaySchedulesPage(int pageKey) async {
    try {
      // Get current day of week
      final currentDay = _getCurrentDayOfWeek();

      // Use selected academy year or null for all years
      final academyYear = selectedAcademyYear.value != 0
          ? selectedAcademyYear.value
          : null; // null = show all years

      // Use selected semester or null for all semesters
      final semester = selectedSemester.value; // can be null

      LoggerUtils.info('=== TODAY SCHEDULES CONTROLLER ===');
      LoggerUtils.info('Controller state:');
      LoggerUtils.info(
          '  selectedAcademyYear.value: ${selectedAcademyYear.value}');
      LoggerUtils.info('  selectedSemester.value: ${selectedSemester.value}');
      LoggerUtils.info('Passing to service:');
      LoggerUtils.info(
          '  academyYear: $academyYear ${academyYear == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info(
          '  semester: $semester ${semester == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info('  dayOfWeek: ${currentDay.name}');
      LoggerUtils.info('  pageNo: $pageKey');
      LoggerUtils.info('===================================');

      final response = await _homeService.getMySchedules(
        academyYear: academyYear, // null = all years
        semester: semester, // null = all semesters
        dayOfWeek: currentDay, // MONDAY, TUESDAY, etc.
        pageNo: pageKey,
        pageSize: 10,
      );

      // Update total elements count
      todayTotalElements.value = response.totalElements;

      final isLastPage = response.last;
      if (isLastPage) {
        todaySchedulesPagingController.appendLastPage(response.content);
      } else {
        final nextPageKey = pageKey + 1;
        todaySchedulesPagingController.appendPage(
            response.content, nextPageKey);
      }

      LoggerUtils.info(
          '✅ Today schedules loaded: ${response.content.length} items (${response.totalElements} total)');
    } catch (e) {
      LoggerUtils.error('❌ Error fetching today schedules page $pageKey', e);
      todaySchedulesPagingController.error = e.toString();
    }
  }

  Future<void> _fetchAllSchedulesPage(int pageKey) async {
    try {
      // Use selected academy year or null for all years
      final academyYear = selectedAcademyYear.value != 0
          ? selectedAcademyYear.value
          : null; // null = show all years

      // Use selected semester or null for all semesters
      final semester = selectedSemester.value; // can be null

      LoggerUtils.info('=== ALL SCHEDULES CONTROLLER ===');
      LoggerUtils.info('Controller state:');
      LoggerUtils.info(
          '  selectedAcademyYear.value: ${selectedAcademyYear.value}');
      LoggerUtils.info('  selectedSemester.value: ${selectedSemester.value}');
      LoggerUtils.info('Passing to service:');
      LoggerUtils.info(
          '  academyYear: $academyYear ${academyYear == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info(
          '  semester: $semester ${semester == null ? "(NO FILTER)" : ""}');
      LoggerUtils.info('  dayOfWeek: null (all days)');
      LoggerUtils.info('  pageNo: $pageKey');
      LoggerUtils.info('================================');

      final response = await _homeService.getMySchedules(
        academyYear: academyYear, // null = all years
        semester: semester, // null = all semesters
        // dayOfWeek is null for all schedules (shows all days)
        pageNo: pageKey,
        pageSize: 10,
      );

      // Update total elements count
      allTotalElements.value = response.totalElements;

      final isLastPage = response.last;
      if (isLastPage) {
        allSchedulesPagingController.appendLastPage(response.content);
      } else {
        final nextPageKey = pageKey + 1;
        allSchedulesPagingController.appendPage(response.content, nextPageKey);
      }

      LoggerUtils.info(
          '✅ All schedules loaded: ${response.content.length} items (${response.totalElements} total)');
    } catch (e) {
      LoggerUtils.error('❌ Error fetching all schedules page $pageKey', e);
      allSchedulesPagingController.error = e.toString();
    }
  }

  // Public methods for UI interactions
  Future<void> refreshSchedules() async {
    try {
      LoggerUtils.info('=== MANUAL REFRESH TRIGGERED ===');
      LoggerUtils.info('Current filter type: ${selectedFilterType.value.name}');

      // Refresh the currently selected filter
      if (selectedFilterType.value == FilterType.today) {
        LoggerUtils.info('Refreshing today schedules...');
        todaySchedulesPagingController.refresh();
      } else {
        LoggerUtils.info('Refreshing all schedules...');
        allSchedulesPagingController.refresh();
      }

      LoggerUtils.info('✅ Refresh initiated successfully');
    } catch (e) {
      LoggerUtils.error('❌ Error refreshing schedules', e);
      ToastUtils.showError('Failed to refresh schedules');
    }
  }

  // Check if any filters are applied (not default values)
  bool get hasActiveFilters {
    final hasFilters = selectedAcademyYear.value != _defaultYear ||
        selectedSemester.value != _defaultSemester;

    LoggerUtils.debug(
        'hasActiveFilters: $hasFilters (year: ${selectedAcademyYear.value}, semester: ${selectedSemester.value})');
    return hasFilters;
  }

  // Clear all filters to default state
  void clearAllFilters() {
    LoggerUtils.info('=== CLEARING ALL FILTERS ===');
    LoggerUtils.info(
        'Before - Year: ${selectedAcademyYear.value}, Semester: ${selectedSemester.value}');

    selectedAcademyYear.value = _defaultYear; // 0 = no filter
    selectedSemester.value = _defaultSemester; // null = no filter

    LoggerUtils.info(
        'After - Year: ${selectedAcademyYear.value}, Semester: ${selectedSemester.value}');
    LoggerUtils.info('============================');

    // Always refresh the currently active tab
    Future.delayed(Duration.zero, () {
      if (selectedFilterType.value == FilterType.today) {
        todaySchedulesPagingController.refresh();
      } else {
        allSchedulesPagingController.refresh();
      }
    });

    ToastUtils.showInfo('Filters cleared');
  }

  void onScheduleTap(ScheduleModel schedule) {
    LoggerUtils.info('Schedule tapped: ${schedule.id}');

    if (schedule.id != null) {
      // Navigate to schedule detail with ID as query parameter
      Get.context?.push('${AppRoutes.scheduleDetailRoute}?id=${schedule.id}');
      LoggerUtils.info('Navigating to schedule detail for ID: ${schedule.id}');
    } else {
      LoggerUtils.warning('Schedule ID is null, cannot navigate to detail');
      ToastUtils.showError('Schedule ID not available');
    }
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

  // Get the total count from API response (totalElements)
  int get todaySchedulesCount {
    return todayTotalElements.value;
  }

  // Get total schedules count from API response (totalElements)
  int get totalSchedulesCount {
    return allTotalElements.value;
  }

  // Debug method to log current state
  void debugCurrentState() {
    LoggerUtils.info('=== CONTROLLER DEBUG STATE ===');
    LoggerUtils.info('selectedFilterType: ${selectedFilterType.value.name}');
    LoggerUtils.info(
        'selectedAcademyYear: ${selectedAcademyYear.value} ${selectedAcademyYear.value == 0 ? "(NO FILTER)" : ""}');
    LoggerUtils.info(
        'selectedSemester: ${selectedSemester.value} ${selectedSemester.value == null ? "(NO FILTER)" : ""}');
    LoggerUtils.info('todayTotalElements: ${todayTotalElements.value}');
    LoggerUtils.info('allTotalElements: ${allTotalElements.value}');
    LoggerUtils.info('hasActiveFilters: $hasActiveFilters');
    LoggerUtils.info('isInitialLoading: ${isInitialLoading.value}');
    LoggerUtils.info('===============================');
  }
}
