import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';
import 'package:ksit_mobile/features/home/widget/home_filter_widget.dart';
import 'package:ksit_mobile/features/home/widget/home_item_widget.dart';
import 'package:ksit_mobile/features/home/widget/home_stats_widget.dart';
import 'package:ksit_mobile/shared/widgets/empty_state_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../controllers/home_controller.dart';
import '../models/home_item_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize service and controller
    Get.put(HomeService());
    final homeController = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: homeController.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: Obx(() {
        if (homeController.isInitialLoading.value) {
          return const LoadingWidget(
            message: 'Loading data...',
            overlay: false,
          );
        }

        return RefreshIndicator(
          onRefresh: homeController.refreshData,
          child: Column(
            children: [
              // Header Section with Stats
              const HomeStatsWidget(),

              // Filter Section
              const HomeFilterWidget(),

              // Items List
              Expanded(
                child: PagedListView<int, HomeItemModel>(
                  pagingController: homeController.pagingController,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  builderDelegate: PagedChildBuilderDelegate<HomeItemModel>(
                    itemBuilder: (context, item, index) => HomeItemWidget(
                      item: item,
                      onTap: () => homeController.onItemTap(item),
                      onStatusChange: (status) =>
                          homeController.updateItemStatus(item, status),
                    ),
                    firstPageErrorIndicatorBuilder: (context) =>
                        ErrorStateWidget(
                      title: 'Something went wrong',
                      message: homeController.pagingController.error.toString(),
                      actionText: 'Try Again',
                      onActionPressed: () =>
                          homeController.pagingController.refresh(),
                    ),
                    newPageErrorIndicatorBuilder: (context) => ErrorStateWidget(
                      title: 'Loading failed',
                      message: homeController.pagingController.error.toString(),
                      actionText: 'Retry',
                      onActionPressed: () => homeController.pagingController
                          .retryLastFailedRequest(),
                      showIcon: false,
                    ),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const LoadingWidget(
                      message: 'Loading items...',
                      overlay: false,
                    ),
                    newPageProgressIndicatorBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    noItemsFoundIndicatorBuilder: (context) =>
                        EmptyStateWidget.noData(
                      title: 'No items found',
                      message: 'Pull to refresh or adjust filters',
                      actionText: 'Refresh',
                      onActionPressed: homeController.refreshData,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
