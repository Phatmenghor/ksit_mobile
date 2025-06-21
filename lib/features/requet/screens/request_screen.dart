import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/features/requet/widget/request_item_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../controllers/request_controller.dart';
import '../models/request_model.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestController = Get.put(RequestController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: requestController.showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: requestController.refreshRequests,
          ),
        ],
      ),
      body: Obx(() {
        if (requestController.isInitialLoading.value) {
          return const LoadingWidget(
            message: 'Loading requests...',
            overlay: false,
          );
        }

        return Column(
          children: [
            // Filter chips
            _buildFilterChips(requestController),

            // Requests list
            Expanded(
              child: RefreshIndicator(
                onRefresh: requestController.refreshRequests,
                child: PagedListView<int, RequestModel>(
                  pagingController: requestController.pagingController,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  builderDelegate: PagedChildBuilderDelegate<RequestModel>(
                    itemBuilder: (context, request, index) => RequestItemWidget(
                      request: request,
                      onTap: () => requestController.onRequestTap(request),
                      onStatusChange: (status) => requestController
                          .updateRequestStatus(request, status),
                    ),
                    firstPageErrorIndicatorBuilder: (context) =>
                        _buildErrorWidget(
                      requestController.pagingController.error.toString(),
                      () => requestController.pagingController.refresh(),
                    ),
                    newPageErrorIndicatorBuilder: (context) =>
                        _buildErrorWidget(
                      requestController.pagingController.error.toString(),
                      () => requestController.pagingController
                          .retryLastFailedRequest(),
                    ),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const LoadingWidget(
                      message: 'Loading requests...',
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
                            Icons.request_page_outlined,
                            size: 64,
                            color: AppColors.iconSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No requests found',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pull to refresh or adjust filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: requestController.refreshRequests,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: requestController.createNewRequest,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips(RequestController controller) {
    return Container(
      height: 60,
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Obx(() {
        return ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip(
              'All',
              controller.selectedStatus.value == null,
              () => controller.setStatusFilter(null),
            ),
            _buildFilterChip(
              'Pending',
              controller.selectedStatus.value == RequestStatus.pending,
              () => controller.setStatusFilter(RequestStatus.pending),
            ),
            _buildFilterChip(
              'In Progress',
              controller.selectedStatus.value == RequestStatus.inProgress,
              () => controller.setStatusFilter(RequestStatus.inProgress),
            ),
            _buildFilterChip(
              'Completed',
              controller.selectedStatus.value == RequestStatus.completed,
              () => controller.setStatusFilter(RequestStatus.completed),
            ),
            _buildFilterChip(
              'Cancelled',
              controller.selectedStatus.value == RequestStatus.cancelled,
              () => controller.setStatusFilter(RequestStatus.cancelled),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
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
