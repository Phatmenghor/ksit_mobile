import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger_utils.dart';
import '../models/home_item_model.dart';

class HomeController extends GetxController {
  // Pagination
  final PagingController<int, HomeItemModel> pagingController =
      PagingController(firstPageKey: 1);

  // Observables
  final RxBool isInitialLoading = true.obs;
  final RxInt totalItems = 0.obs;
  final RxInt activeItems = 0.obs;
  final RxInt pendingItems = 0.obs;
  final RxInt completedItems = 0.obs;

  // Static mock data
  static final List<HomeItemModel> _mockItems = [
    HomeItemModel(
      id: 1,
      title: 'Website Development',
      description: 'Complete responsive website for client project',
      status: ItemStatus.active,
      priority: 3,
      category: 'Development',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    HomeItemModel(
      id: 2,
      title: 'Mobile App Testing',
      description: 'Test all features and fix bugs in mobile application',
      status: ItemStatus.pending,
      priority: 2,
      category: 'Testing',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    HomeItemModel(
      id: 3,
      title: 'Database Optimization',
      description: 'Optimize database queries for better performance',
      status: ItemStatus.completed,
      priority: 1,
      category: 'Database',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HomeItemModel(
      id: 4,
      title: 'UI/UX Design Review',
      description: 'Review and update user interface designs',
      status: ItemStatus.active,
      priority: 2,
      category: 'Design',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    HomeItemModel(
      id: 5,
      title: 'API Documentation',
      description: 'Create comprehensive API documentation for developers',
      status: ItemStatus.pending,
      priority: 1,
      category: 'Documentation',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HomeItemModel(
      id: 6,
      title: 'Security Audit',
      description: 'Perform security audit and vulnerability assessment',
      status: ItemStatus.active,
      priority: 3,
      category: 'Security',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    HomeItemModel(
      id: 7,
      title: 'Performance Monitoring',
      description: 'Set up monitoring tools for application performance',
      status: ItemStatus.completed,
      priority: 2,
      category: 'Monitoring',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HomeItemModel(
      id: 8,
      title: 'User Training',
      description: 'Conduct training sessions for end users',
      status: ItemStatus.pending,
      priority: 1,
      category: 'Training',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

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
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Calculate stats from mock data
      totalItems.value = _mockItems.length;
      activeItems.value =
          _mockItems.where((item) => item.status == ItemStatus.active).length;
      pendingItems.value =
          _mockItems.where((item) => item.status == ItemStatus.pending).length;
      completedItems.value = _mockItems
          .where((item) => item.status == ItemStatus.completed)
          .length;

      LoggerUtils.info('Stats loaded successfully');
    } catch (e) {
      LoggerUtils.error('Error loading stats', e);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final pageSize = AppConstants.defaultPageSize;
      final startIndex = (pageKey - 1) * pageSize;
      final endIndex = startIndex + pageSize;

      List<HomeItemModel> pageItems;
      if (startIndex >= _mockItems.length) {
        pageItems = [];
      } else {
        pageItems = _mockItems.sublist(
          startIndex,
          endIndex > _mockItems.length ? _mockItems.length : endIndex,
        );
      }

      final isLastPage = endIndex >= _mockItems.length;

      if (isLastPage) {
        pagingController.appendLastPage(pageItems);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(pageItems, nextPageKey);
      }

      LoggerUtils.info('Page $pageKey loaded with ${pageItems.length} items');
    } catch (e) {
      LoggerUtils.error('Error fetching page $pageKey', e);
      pagingController.error = e.toString();
    }
  }

  Future<void> refreshData() async {
    try {
      await _loadStats();
      pagingController.refresh();
      LoggerUtils.info('Data refreshed successfully');
    } catch (e) {
      LoggerUtils.error('Error refreshing data', e);
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
