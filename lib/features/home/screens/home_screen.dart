// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/features/home/controllers/home_controller.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import 'package:ksit_mobile/features/home/widget/schedule_filter_widget.dart';
import 'package:ksit_mobile/features/home/widget/schedule_class_widget.dart';
import 'package:ksit_mobile/shared/widgets/empty_state_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../models/schedule_models.dart';

enum FilterType { all, today }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize service and controller
    Get.put(HomeService());
    final scheduleController = Get.put(ScheduleController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (scheduleController.isInitialLoading.value) {
          return const LoadingWidget(
            overlay: false,
          );
        }

        return RefreshIndicator(
          onRefresh: scheduleController.refreshSchedules,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                floating: true,
                snap: true,
                toolbarHeight: 70, // Custom height
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          AppImages.logoSchool,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Kampong Speu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Institute of Technology',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // actions: [
                //   IconButton(
                //     icon: const Icon(Icons.notifications_outlined),
                //     onPressed: () {
                //       // Handle notifications
                //     },
                //   ),
                //   IconButton(
                //     icon: const Icon(Icons.more_vert),
                //     onPressed: () {
                //       // Handle menu
                //     },
                //   ),
                // ],
              ),

              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Schedules',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        final count =
                            scheduleController.selectedFilterType.value ==
                                    FilterType.today
                                ? scheduleController.todayTotalElements.value
                                : scheduleController.allTotalElements.value;

                        return Text(
                          '$count Schedules',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Filter Tabs
              SliverToBoxAdapter(
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildAppBarFilterButton(
                            text: 'Today',
                            isSelected:
                                scheduleController.selectedFilterType.value ==
                                    FilterType.today,
                            onTap: () => scheduleController
                                .setFilterType(FilterType.today),
                          ),
                          const SizedBox(width: 8),
                          _buildAppBarFilterButton(
                            text: 'All Schedule',
                            isSelected:
                                scheduleController.selectedFilterType.value ==
                                    FilterType.all,
                            onTap: () => scheduleController
                                .setFilterType(FilterType.all),
                          ),
                        ],
                      ),
                    )),
              ),

              // Schedule Filter Widget
              SliverToBoxAdapter(
                child: ScheduleFilterWidget(
                  availableYears: scheduleController.availableAcademyYears,
                  selectedYear: scheduleController.selectedAcademyYear.value,
                  availableSemesters: scheduleController.availableSemesters,
                  selectedSemester: scheduleController.selectedSemester.value,
                  onYearChanged: scheduleController.setAcademyYear,
                  onSemesterChanged: scheduleController.setSemester,
                  onSemesterCleared: scheduleController.clearSemester,
                  onClearFilters: scheduleController.clearAllFilters,
                ),
              ),

              // Schedules List
              _buildSchedulesList(scheduleController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAppBarFilterButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? AppColors.white
                : AppColors.textPrimary.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulesList(ScheduleController controller) {
    return Obx(() {
      // Show today's schedules when Today filter is selected
      if (controller.selectedFilterType.value == FilterType.today) {
        return _buildTodaySchedules(controller);
      }

      // Show all schedules when All filter is selected
      return _buildAllSchedules(controller);
    });
  }

  Widget _buildTodaySchedules(ScheduleController controller) {
    return PagedSliverList<int, ScheduleModel>(
      key: const ValueKey('today_schedules'), // Add unique key
      pagingController: controller.todaySchedulesPagingController,
      builderDelegate: PagedChildBuilderDelegate<ScheduleModel>(
        itemBuilder: (context, schedule, index) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 16 : 0,
            16,
            12,
          ),
          child: ScheduleClassWidget(
            schedule: schedule,
            onTap: () => controller.onScheduleTap(schedule),
            statusText: controller.getScheduleStatusText(schedule),
            statusColor: controller.getScheduleStatusColor(schedule),
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
          controller.todaySchedulesPagingController.error.toString(),
          () => controller.todaySchedulesPagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
          controller.todaySchedulesPagingController.error.toString(),
          () => controller.todaySchedulesPagingController
              .retryLastFailedRequest(),
          isNewPage: true,
        ),
        firstPageProgressIndicatorBuilder: (context) => const LoadingWidget(
          message: 'Loading today\'s schedules...',
          overlay: false,
        ),
        newPageProgressIndicatorBuilder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: EmptyStateWidget.noData(
            title: 'No Classes Today',
            message:
                'You don\'t have any classes scheduled for today.\nEnjoy your free time! 🎉',
            actionText: 'Refresh',
            onActionPressed: controller.refreshSchedules,
          ),
        ),
      ),
    );
  }

  Widget _buildAllSchedules(ScheduleController controller) {
    return PagedSliverList<int, ScheduleModel>(
      key: const ValueKey('all_schedules'), // Add unique key
      pagingController: controller.allSchedulesPagingController,
      builderDelegate: PagedChildBuilderDelegate<ScheduleModel>(
        itemBuilder: (context, schedule, index) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 16 : 0,
            16,
            12,
          ),
          child: ScheduleClassWidget(
            schedule: schedule,
            onTap: () => controller.onScheduleTap(schedule),
            statusText: controller.getScheduleStatusText(schedule),
            statusColor: controller.getScheduleStatusColor(schedule),
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
          controller.allSchedulesPagingController.error.toString(),
          () => controller.allSchedulesPagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
          controller.allSchedulesPagingController.error.toString(),
          () =>
              controller.allSchedulesPagingController.retryLastFailedRequest(),
          isNewPage: true,
        ),
        firstPageProgressIndicatorBuilder: (context) => const LoadingWidget(
          message: 'Loading schedules...',
          overlay: false,
        ),
        newPageProgressIndicatorBuilder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: EmptyStateWidget.noData(
            title: 'No Schedules Found',
            message:
                'No schedules available for the selected filters.\nTry adjusting your selection.',
            actionText: 'Refresh',
            onActionPressed: controller.refreshSchedules,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry,
      {bool isNewPage = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNewPage) ...[
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              isNewPage ? 'Failed to load more' : error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isNewPage ? 'Retry' : 'Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
