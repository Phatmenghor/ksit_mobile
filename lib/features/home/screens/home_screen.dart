// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/features/home/controllers/home_controller.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import 'package:ksit_mobile/features/home/widget/schedule_filter_widget.dart';
import 'package:ksit_mobile/features/home/widget/schedule_item_widget.dart';
import 'package:ksit_mobile/shared/widgets/empty_state_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../models/schedule_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize service and controller
    Get.put(HomeService());
    final scheduleController = Get.put(ScheduleController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (scheduleController.isInitialLoading.value) {
          return const LoadingWidget(
            message: 'Loading schedules...',
            overlay: false,
          );
        }

        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'My Schedules',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: scheduleController.refreshSchedules,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ];
          },
          body: Column(
            children: [
              // Filter Section
              ScheduleFilterWidget(
                availableYears: scheduleController.availableAcademyYears,
                selectedYear: scheduleController.selectedAcademyYear.value,
                availableSemesters: scheduleController.availableSemesters,
                selectedSemester: scheduleController.selectedSemester.value,
                onYearChanged: scheduleController.setAcademyYear,
                onSemesterChanged: scheduleController.setSemester,
              ),

              // Tab Bar with better styling
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: scheduleController.tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.today_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Today'),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.calendar_month_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('All Schedule'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: scheduleController.tabController,
                  children: [
                    // Today Tab
                    _buildTodayTab(scheduleController),

                    // All Schedules Tab
                    _buildAllSchedulesTab(scheduleController),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTodayTab(ScheduleController controller) {
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
            child: Container(
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
              onTap: () => controller.onScheduleTap(schedule),
              statusText: controller.getScheduleStatusText(schedule),
              statusColor: controller.getScheduleStatusColor(schedule),
            );
          },
        );
      }),
    );
  }

  Widget _buildAllSchedulesTab(ScheduleController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshSchedules,
      color: AppColors.primary,
      child: PagedListView<int, ScheduleModel>(
        pagingController: controller.allSchedulesPagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<ScheduleModel>(
          itemBuilder: (context, schedule, index) => ScheduleItemWidget(
            schedule: schedule,
            onTap: () => controller.onScheduleTap(schedule),
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
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(Get.context!).size.height * 0.6,
              child: EmptyStateWidget.noData(
                title: 'No Schedules Found',
                message:
                    'No schedules available for the selected filters.\nTry adjusting your year or semester selection.',
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
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNewPage) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
