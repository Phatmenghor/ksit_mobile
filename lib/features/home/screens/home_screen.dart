// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/features/home/controllers/home_controller.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import 'package:ksit_mobile/features/home/widget/schedule_filter_widget.dart';
import 'package:ksit_mobile/features/home/widget/schedule_item_widget.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
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
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kampong Speu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Institute of Technology',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false, // This removes the default back button
      ),
      body: Obx(() {
        if (scheduleController.isInitialLoading.value) {
          return const LoadingWidget(
            message: 'Loading schedules...',
            overlay: false,
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Schedules',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '4 Schedules',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildAppBarFilterButton(
                      text: 'Today',
                      isSelected: scheduleController.selectedFilterType.value ==
                          FilterType.today,
                      onTap: () =>
                          scheduleController.setFilterType(FilterType.today),
                    ),
                    const SizedBox(width: 8),
                    _buildAppBarFilterButton(
                      text: 'All Schedule',
                      isSelected: scheduleController.selectedFilterType.value ==
                          FilterType.all,
                      onTap: () =>
                          scheduleController.setFilterType(FilterType.all),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),

            // Schedules List
            Expanded(
              child: _buildSchedulesList(scheduleController),
            ),

            // Bottom Filter Section (Academy Year & Semester)
            ScheduleFilterWidget(
              availableYears: scheduleController.availableAcademyYears,
              selectedYear: scheduleController.selectedAcademyYear.value,
              availableSemesters: scheduleController.availableSemesters,
              selectedSemester: scheduleController.selectedSemester.value,
              onYearChanged: scheduleController.setAcademyYear,
              onSemesterChanged: scheduleController.setSemester,
              onSemesterCleared: scheduleController.clearSemester,
              onClearFilters: scheduleController.clearAllFilters,
            ),
          ],
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
    return RefreshIndicator(
      onRefresh: controller.refreshSchedules,
      color: AppColors.primary,
      child: Obx(() {
        if (controller.isTodayLoading.value) {
          return const LoadingWidget(
            message: 'Loading today\'s schedules...',
            overlay: false,
          );
        }

        if (controller.todaySchedules.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(Get.context!).size.height * 0.6,
              child: EmptyStateWidget.noData(
                title: 'No Classes Today',
                message:
                    'You don\'t have any classes scheduled for today.\nEnjoy your free time! 🎉',
                actionText: 'Refresh',
                onActionPressed: controller.refreshSchedules,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.todaySchedules.length,
          itemBuilder: (context, index) {
            final schedule = controller.todaySchedules[index];
            return ScheduleItemWidget(
              schedule: schedule,
              onTap: () {
                // TODO: Navigate to detail screen
              },
              statusText: controller.getScheduleStatusText(schedule),
              statusColor: controller.getScheduleStatusColor(schedule),
            );
          },
        );
      }),
    );
  }

  Widget _buildAllSchedules(ScheduleController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshSchedules,
      color: AppColors.primary,
      child: PagedListView<int, ScheduleModel>(
        pagingController: controller.allSchedulesPagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<ScheduleModel>(
          itemBuilder: (context, schedule, index) => ScheduleItemWidget(
            schedule: schedule,
            onTap: () {
              // TODO: Navigate to detail screen
            },
            statusText: controller.getScheduleStatusText(schedule),
            statusColor: controller.getScheduleStatusColor(schedule),
          ),
          firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
            controller.allSchedulesPagingController.error.toString(),
            () => controller.allSchedulesPagingController.refresh(),
          ),
          newPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
            controller.allSchedulesPagingController.error.toString(),
            () => controller.allSchedulesPagingController
                .retryLastFailedRequest(),
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
          noItemsFoundIndicatorBuilder: (context) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(Get.context!).size.height * 0.6,
              child: EmptyStateWidget.noData(
                title: 'No Schedules Found',
                message:
                    'No schedules available for the selected filters.\nTry adjusting your selection.',
                actionText: 'Refresh',
                onActionPressed: controller.refreshSchedules,
              ),
            ),
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
