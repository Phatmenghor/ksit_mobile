import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/features/home/widget/home_item_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../controllers/home_controller.dart';
import '../models/home_item_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Header Section
              _buildHeaderSection(homeController),

              // Items List
              Expanded(
                child: _buildItemsList(homeController),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection(HomeController controller) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.dashboard,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Obx(() => Text(
                    'Total: ${controller.totalItems.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                title: 'Active',
                value: controller.activeItems.value.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Pending',
                value: controller.pendingItems.value.toString(),
                color: AppColors.warning,
                icon: Icons.pending_outlined,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Completed',
                value: controller.completedItems.value.toString(),
                color: AppColors.info,
                icon: Icons.done_all_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(HomeController controller) {
    return PagedListView<int, HomeItemModel>(
      pagingController: controller.pagingController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      builderDelegate: PagedChildBuilderDelegate<HomeItemModel>(
        itemBuilder: (context, item, index) => HomeItemWidget(
          item: item,
          onTap: () => controller.onItemTap(item),
        ),
        firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
          controller.pagingController.error.toString(),
          () => controller.pagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) => _buildErrorWidget(
          controller.pagingController.error.toString(),
          () => controller.pagingController.retryLastFailedRequest(),
        ),
        firstPageProgressIndicatorBuilder: (context) => const LoadingWidget(
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
        noItemsFoundIndicatorBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.iconSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'No items found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pull to refresh or try again later',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.refreshData,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
