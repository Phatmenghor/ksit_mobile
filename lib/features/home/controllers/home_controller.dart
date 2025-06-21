import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../shared/models/api_response/api_response_model.dart';
import '../models/home_item_model.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Pagination
  final PagingController<int, HomeItemModel> pagingController =
      PagingController(firstPageKey: 1);

  // Observables
  final RxBool isInitialLoading = true.obs;
  final RxInt totalItems = 0.obs;
  final RxInt activeItems = 0.obs;
  final RxInt pendingItems = 0.obs;
  final RxInt completedItems = 0.obs;

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
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.homeDataEndpoint}/stats',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        totalItems.value = data['total'] ?? 0;
        activeItems.value = data['active'] ?? 0;
        pendingItems.value = data['pending'] ?? 0;
        completedItems.value = data['completed'] ?? 0;
      }
    } catch (e) {
      LoggerUtils.error('Error loading stats', e);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.homeDataEndpoint,
        queryParameters: {
          'pageNo': pageKey - 1, // API uses 0-based indexing
          'pageSize': AppConstants.defaultPageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse =
            ApiResponse<PaginatedResponse<HomeItemModel>>.fromJson(
          response.data!,
          (json) => PaginatedResponse<HomeItemModel>.fromJson(
            json as Map<String, dynamic>,
            (itemJson) =>
                HomeItemModel.fromJson(itemJson as Map<String, dynamic>),
          ),
        );

        if (apiResponse.success && apiResponse.data != null) {
          final paginatedData = apiResponse.data!;
          final newItems = paginatedData.content;
          final isLastPage = paginatedData.last;

          if (isLastPage) {
            pagingController.appendLastPage(newItems);
          } else {
            final nextPageKey = pageKey + 1;
            pagingController.appendPage(newItems, nextPageKey);
          }

          // Update total items
          totalItems.value = paginatedData.totalElements;
        } else {
          pagingController.error = apiResponse.message;
        }
      } else {
        pagingController.error = 'Failed to load data';
      }
    } catch (e) {
      LoggerUtils.error('Error fetching page $pageKey', e);
      pagingController.error = e.toString();
    }
  }

  Future<void> refreshData() async {
    try {
      await _loadStats();
      pagingController.refresh();
    } catch (e) {
      LoggerUtils.error('Error refreshing data', e);
    }
  }

  void onItemTap(HomeItemModel item) {
    LoggerUtils.info('Item tapped: ${item.id}');
    // TODO: Navigate to item details or perform action
    Get.snackbar(
      'Item Selected',
      'Tapped on ${item.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
