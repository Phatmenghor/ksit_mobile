// lib/features/attendance/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/features/attandance/controllers/attendance_controller.dart';
import 'package:ksit_mobile/features/attandance/models/attendance_models.dart';
import 'package:ksit_mobile/features/attandance/services/attendance_service.dart';
import 'package:ksit_mobile/features/attandance/widgets/attendance_filter_widget.dart';
import 'package:ksit_mobile/features/attandance/widgets/attendance_item_widget.dart';
import 'package:ksit_mobile/shared/widgets/loading_widget.dart';
import 'package:ksit_mobile/core/utils/pagination_utils.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize service and controller
    Get.put(AttendanceService());
    final attendanceController = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attendance History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() => attendanceController.hasActiveFilters
              ? IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.white),
                  onPressed: attendanceController.clearAllFilters,
                  tooltip: 'Clear Filters',
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (attendanceController.isInitialLoading.value) {
          return const LoadingWidget(
            message: '',
            overlay: false,
          );
        }

        return RefreshIndicator(
          onRefresh: attendanceController.refreshAttendance,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Filter Section
              SliverToBoxAdapter(
                child: AttendanceFilterWidget(
                  availableYears: attendanceController.availableAcademyYears,
                  selectedYear: attendanceController.selectedAcademyYear.value,
                  availableSemesters: attendanceController.availableSemesters,
                  selectedSemester: attendanceController.selectedSemester.value,
                  onYearChanged: attendanceController.setAcademyYear,
                  onSemesterChanged: attendanceController.setSemester,
                  onSemesterCleared: attendanceController.clearSemester,
                  onClearFilters: attendanceController.clearAllFilters,
                ),
              ),

              // Attendance List
              _buildAttendanceList(attendanceController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAttendanceList(AttendanceController controller) {
    return PagedSliverList<int, AttendanceHistoryModel>(
      pagingController: controller.pagingController,
      builderDelegate:
          PaginationUtils.getCommonBuilderDelegate<AttendanceHistoryModel>(
        itemBuilder: (context, attendance, index) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 8 : 0,
            16,
            12,
          ),
          child: AttendanceItemWidget(
            attendance: attendance,
            onTap: () => _showAttendanceDetails(context, attendance),
          ),
        ),
        loadingMessage: 'Loading attendance records...',
        emptyTitle: 'No Attendance Records',
        emptyMessage:
            'No attendance records found for the selected criteria.\nTry adjusting your filters.',
        emptyActionText: 'Clear Filters',
        onEmptyActionPressed:
            controller.hasActiveFilters ? controller.clearAllFilters : null,
        onErrorRetry: () => controller.pagingController.refresh(),
      ),
    );
  }

  void _showAttendanceDetails(
      BuildContext context, AttendanceHistoryModel attendance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Attendance Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Course', attendance.displayCourseName),
                    _buildDetailRow('Status', attendance.displayStatus),
                    _buildDetailRow(
                        'Attendance Type', attendance.displayAttendanceType),
                    _buildDetailRow(
                        'Student ID', attendance.identifyNumber ?? 'N/A'),
                    _buildDetailRow('Teacher', attendance.displayTeacherName),
                    _buildDetailRow('Date', attendance.displayDate),
                    if (attendance.recordedTime != null &&
                        attendance.recordedTime!.isNotEmpty)
                      _buildDetailRow(
                          'Recorded Time', attendance.displayRecordedTime),
                    _buildDetailRow('Finalization Status',
                        attendance.displayFinalizationStatus),
                    if (attendance.comment != null &&
                        attendance.comment!.isNotEmpty)
                      _buildDetailRow('Comment', attendance.comment!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
