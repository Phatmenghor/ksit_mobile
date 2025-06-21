import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger_utils.dart';
import '../models/home_item_model.dart';

class HomeController extends GetxController {
  final HomeService _homeService = Get.find<HomeService>();

  // Pagination
  final PagingController<int, HomeItemModel> pagingController =
      PagingController(firstPageKey: 1);

  // Observables
  final RxBool isInitialLoading = true.obs;
  final RxInt totalItems = 0.obs;
  final RxInt activeItems = 0.obs;
  final RxInt pendingItems = 0.obs;
  final RxInt completedItems = 0.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ItemStatus?> selectedStatus = Rx<ItemStatus?>(null);

  @override
  void onInit() {
    super.onInit();
    _setupPagination();
    _loadInitialData();
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }

  void _setupPagination() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _loadInitialData() async {
    try {
      isInitialLoading.value = true;
      await _loadStats();
      pagingController.refresh();
    } catch (e) {
      LoggerUtils.error('Error loading initial data', e);
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _homeService.getHomeStats();

      totalItems.value = stats['total'] ?? 0;
      activeItems.value = stats['active'] ?? 0;
      pendingItems.value = stats['pending'] ?? 0;
      completedItems.value = stats['completed'] ?? 0;

      LoggerUtils.info('Stats loaded successfully');
    } catch (e) {
      LoggerUtils.error('Error loading stats', e);
      // Set default values on error
      totalItems.value = 0;
      activeItems.value = 0;
      pendingItems.value = 0;
      completedItems.value = 0;
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final items = await _homeService.getHomeItems(
        page: pageKey,
        limit: AppConstants.defaultPageSize,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: selectedStatus.value,
      );

      final isLastPage = items.length < AppConstants.defaultPageSize;

      if (isLastPage) {
        pagingController.appendLastPage(items);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(items, nextPageKey);
      }

      LoggerUtils.info('Page $pageKey loaded with ${items.length} items');
    } catch (e) {
      LoggerUtils.error('Error fetching page $pageKey', e);
      pagingController.error = e.toString();
    }
  }

  // Public methods for UI interactions
  Future<void> refreshData() async {
    try {
      await _loadStats();
      pagingController.refresh();
      LoggerUtils.info('Data refreshed successfully');
    } catch (e) {
      LoggerUtils.error('Error refreshing data', e);
    }
  }

  void setStatusFilter(ItemStatus? status) {
    selectedStatus.value = status;
    pagingController.refresh();
    LoggerUtils.info('Status filter set to: ${status?.name ?? 'All'}');
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    pagingController.refresh();
    LoggerUtils.info('Search query set to: $query');
  }

  Future<void> updateItemStatus(
      HomeItemModel item, ItemStatus newStatus) async {
    try {
      final success = await _homeService.updateItemStatus(item.id, newStatus);
      if (success) {
        pagingController.refresh();
        Get.snackbar(
          'Success',
          'Item status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      LoggerUtils.error('Error updating item status', e);
      Get.snackbar(
        'Error',
        'Failed to update item status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onItemTap(HomeItemModel item) {
    LoggerUtils.info('Item tapped: ${item.id}');
    Get.snackbar(
      'Item Selected',
      'Tapped on ${item.title}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
