// lib/features/home/controllers/schedule_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/core/utils/toast_utils.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import '../models/schedule_models.dart';

class ScheduleController extends GetxController
    with GetTickerProviderStateMixin {
  final HomeService _homeService = Get.find<HomeService>();

  // Tab Controller
  late TabController tabController;

  // Observables
  final RxBool isInitialLoading = true.obs;
  final RxInt selectedAcademyYear = DateTime.now().year.obs;
  final Rx<Semester> selectedSemester = Semester.semester1.obs;
  final RxList<int> availableAcademyYears = <int>[].obs;
  final RxList<Semester> availableSemesters = <Semester>[].obs;

  // Today's schedules
  final RxList<ScheduleModel> todaySchedules = <ScheduleModel>[].obs;
  final RxBool isTodayLoading = false.obs;

  // All schedules pagination
  final PagingController<int, ScheduleModel> allSchedulesPagingController =
      PagingController(firstPageKey: 1);

  // Statistics
  final RxInt totalSchedulesToday = 0.obs;
  final RxInt totalSchedulesAll = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTabController();
    _setupPagination();
    _loadInitialData();
  }

  @override
  void onClose() {
    tabController.dispose();
    allSchedulesPagingController.dispose();
    super.onClose();
  }

  void _initializeTabController() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onTabChanged);
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

      // Load today's schedules
      await _loadTodaySchedules();

      // Initialize all schedules pagination
      allSchedulesPagingController.refresh();

      LoggerUtils.info('Initial schedule data loaded successfully');
    } catch (e) {
      LoggerUtils.error('Error loading initial schedule data', e);
      ToastUtils.showError('Failed to load schedules');
    } finally {
      isInitialLoading.value = false;
    }
  }

  void _onTabChanged() {
    if (tabController.index == 0) {
      // Today tab selected
      _loadTodaySchedules();
    } else {
      // All schedules tab selected
      if (allSchedulesPagingController.itemList?.isEmpty ?? true) {
        allSchedulesPagingController.refresh();
      }
    }
  }

  Future<void> _loadTodaySchedules() async {
    try {
      isTodayLoading.value = true;

      // Get current day of week
      final currentDay = _getCurrentDayOfWeek();

      final response = await _homeService.getMySchedules(
        academyYear: selectedAcademyYear.value,
        semester: selectedSemester.value,
        dayOfWeek: currentDay,
        pageSize: 50, // Get more items for today
      );

      todaySchedules.assignAll(response.content);
      totalSchedulesToday.value = response.totalElements;

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
      final response = await _homeService.getMySchedules(
        academyYear: selectedAcademyYear.value,
        semester: selectedSemester.value,
        // dayOfWeek is null for all schedules
        pageNo: pageKey,
        pageSize: 10,
      );

      totalSchedulesAll.value = response.totalElements;

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
      if (tabController.index == 0) {
        // Refresh today's schedules
        await _loadTodaySchedules();
      } else {
        // Refresh all schedules
        allSchedulesPagingController.refresh();
      }
      LoggerUtils.info('Schedules refreshed successfully');
    } catch (e) {
      LoggerUtils.error('Error refreshing schedules', e);
      ToastUtils.showError('Failed to refresh schedules');
    }
  }

  void setAcademyYear(int year) {
    if (selectedAcademyYear.value != year) {
      selectedAcademyYear.value = year;
      _onFiltersChanged();
      LoggerUtils.info('Academy year changed to: $year');
    }
  }

  void setSemester(Semester semester) {
    if (selectedSemester.value != semester) {
      selectedSemester.value = semester;
      _onFiltersChanged();
      LoggerUtils.info('Semester changed to: ${semester.displayName}');
    }
  }

  void _onFiltersChanged() {
    // Refresh both today and all schedules when filters change
    _loadTodaySchedules();
    allSchedulesPagingController.refresh();
  }

  void onScheduleTap(ScheduleModel schedule) {
    LoggerUtils.info('Schedule tapped: ${schedule.id}');
    _showScheduleDetails(schedule);
  }

  void _showScheduleDetails(ScheduleModel schedule) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Schedule Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard('Course Information', [
                      _buildDetailRow('Course Name',
                          schedule.course?.displayName ?? 'Unknown Course'),
                      _buildDetailRow('Course Code',
                          schedule.course?.code ?? 'Unknown Code'),
                      _buildDetailRow(
                          'Subject',
                          schedule.course?.subject?.displayName ??
                              'Unknown Subject'),
                      _buildDetailRow(
                          'Credits', '${schedule.course?.displayCredit ?? 0}'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailCard('Schedule Information', [
                      _buildDetailRow('Day', schedule.dayDisplayName),
                      _buildDetailRow('Time', schedule.timeRange),
                      _buildDetailRow(
                          'Room', schedule.room?.displayName ?? 'Unknown Room'),
                      _buildDetailRow('Class',
                          schedule.classes?.displayCode ?? 'Unknown Class'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailCard('Teacher Information', [
                      _buildDetailRow('Name',
                          schedule.teacher?.displayName ?? 'Unknown Teacher'),
                      _buildDetailRow(
                          'Email', schedule.teacher?.email ?? 'N/A'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailCard('Semester Information', [
                      _buildDetailRow('Semester',
                          schedule.semester?.displayName ?? 'Unknown Semester'),
                      _buildDetailRow('Academy Year',
                          '${schedule.semester?.academyYear ?? schedule.academyYear ?? 'N/A'}'),
                      _buildDetailRow(
                          'Major',
                          schedule.classes?.major?.displayName ??
                              'Unknown Major'),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
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
