import 'package:get/get.dart';
import 'package:ksit_mobile/core/services/api_service.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/features/home/models/home_item_model.dart';

class HomeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Get home statistics
  Future<Map<String, int>> getHomeStats() async {
    try {
      // Simulate API call - replace with real API later
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API call
      return {
        'total': 25,
        'active': 8,
        'pending': 5,
        'completed': 12,
      };

      // Future real API call:
      // final response = await _apiService.get('/home/stats');
      // return response.data;
    } catch (e) {
      LoggerUtils.error('Error fetching home stats', e);
      rethrow;
    }
  }

  // Get paginated home items
  Future<List<HomeItemModel>> getHomeItems({
    required int page,
    required int limit,
    String? search,
    ItemStatus? status,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data - replace with real API later
      final mockItems = _generateMockItems();

      // Apply filters
      var filteredItems = mockItems;
      if (status != null) {
        filteredItems =
            filteredItems.where((item) => item.status == status).toList();
      }
      if (search != null && search.isNotEmpty) {
        filteredItems = filteredItems
            .where((item) =>
                item.title.toLowerCase().contains(search.toLowerCase()) ||
                item.description.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= filteredItems.length) {
        return [];
      }

      return filteredItems.sublist(
        startIndex,
        endIndex > filteredItems.length ? filteredItems.length : endIndex,
      );

      // Future real API call:
      // final response = await _apiService.get('/home/items', queryParameters: {
      //   'page': page,
      //   'limit': limit,
      //   if (search != null) 'search': search,
      //   if (status != null) 'status': status.name,
      // });
      // return (response.data['items'] as List)
      //     .map((item) => HomeItemModel.fromJson(item))
      //     .toList();
    } catch (e) {
      LoggerUtils.error('Error fetching home items', e);
      rethrow;
    }
  }

  // Update item status
  Future<bool> updateItemStatus(int itemId, ItemStatus newStatus) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      LoggerUtils.info('Updated item $itemId to status: ${newStatus.name}');
      return true;

      // Future real API call:
      // final response = await _apiService.put('/home/items/$itemId/status', data: {
      //   'status': newStatus.name,
      // });
      // return response.data['success'] ?? false;
    } catch (e) {
      LoggerUtils.error('Error updating item status', e);
      rethrow;
    }
  }

  List<HomeItemModel> _generateMockItems() {
    return [
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
      // Add more mock items...
    ];
  }
}
