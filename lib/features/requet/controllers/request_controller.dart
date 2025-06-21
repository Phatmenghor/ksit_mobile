import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../shared/models/api_response/api_response_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/request_model.dart';

class RequestController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Pagination
  final PagingController<int, RequestModel> pagingController =
      PagingController(firstPageKey: 1);

  // Observables
  final RxBool isInitialLoading = true.obs;
  final Rx<RequestStatus?> selectedStatus = Rx<RequestStatus?>(null);

  // Form controllers for new request
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<RequestPriority> selectedPriority = RequestPriority.medium.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _setupPagination();
    _loadInitialData();
  }

  @override
  void onClose() {
    pagingController.dispose();
    titleController.dispose();
    descriptionController.dispose();
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
      pagingController.refresh();
    } catch (e) {
      LoggerUtils.error('Error loading initial data', e);
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      Map<String, dynamic> queryParams = {
        'pageNo': pageKey - 1, // API uses 0-based indexing
        'pageSize': AppConstants.defaultPageSize,
      };

      // Add status filter if selected
      if (selectedStatus.value != null) {
        queryParams['status'] = selectedStatus.value!.name;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.requestsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse =
            ApiResponse<PaginatedResponse<RequestModel>>.fromJson(
          response.data!,
          (json) => PaginatedResponse<RequestModel>.fromJson(
            json as Map<String, dynamic>,
            (itemJson) =>
                RequestModel.fromJson(itemJson as Map<String, dynamic>),
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
        } else {
          pagingController.error = apiResponse.message;
        }
      } else {
        pagingController.error = 'Failed to load requests';
      }
    } catch (e) {
      LoggerUtils.error('Error fetching page $pageKey', e);
      pagingController.error = e.toString();
    }
  }

  Future<void> refreshRequests() async {
    try {
      pagingController.refresh();
    } catch (e) {
      LoggerUtils.error('Error refreshing requests', e);
    }
  }

  void setStatusFilter(RequestStatus? status) {
    selectedStatus.value = status;
    pagingController.refresh();
  }

  void onRequestTap(RequestModel request) {
    LoggerUtils.info('Request tapped: ${request.id}');
    _showRequestDetails(request);
  }

  void _showRequestDetails(RequestModel request) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Request Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'Status', request.status.name.toUpperCase()),
                    _buildDetailRow(
                        'Priority', request.priority.name.toUpperCase()),
                    _buildDetailRow('Type', request.type ?? 'General'),
                    if (request.createdAt != null)
                      _buildDetailRow(
                          'Created', _formatDateTime(request.createdAt!)),
                    if (request.updatedAt != null)
                      _buildDetailRow(
                          'Updated', _formatDateTime(request.updatedAt!)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> updateRequestStatus(
      RequestModel request, RequestStatus newStatus) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.requestsEndpoint}/${request.id}/status',
        data: {'status': newStatus.name},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Status updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        pagingController.refresh();
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      LoggerUtils.error('Error updating request status', e);
      Fluttertoast.showToast(
        msg: 'Failed to update status',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void createNewRequest() {
    _clearForm();

    Get.dialog(
      AlertDialog(
        title: const Text('Create New Request'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Title',
                  controller: titleController,
                  validator: _validateTitle,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  controller: descriptionController,
                  maxLines: 3,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<RequestPriority>(
                      value: selectedPriority.value,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: RequestPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedPriority.value = value;
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Create',
            onPressed: _submitNewRequest,
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = RequestPriority.medium;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  Future<void> _submitNewRequest() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final requestData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'priority': selectedPriority.value.name,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.requestsEndpoint,
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); // Close dialog

        Fluttertoast.showToast(
          msg: 'Request created successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        pagingController.refresh();
        _clearForm();
      } else {
        throw Exception('Failed to create request');
      }
    } catch (e) {
      LoggerUtils.error('Error creating request', e);
      Fluttertoast.showToast(
        msg: 'Failed to create request',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Requests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select status to filter:'),
            const SizedBox(height: 16),
            ...RequestStatus.values.map((status) {
              return Obx(() => RadioListTile<RequestStatus?>(
                    title: Text(status.name.toUpperCase()),
                    value: status,
                    groupValue: selectedStatus.value,
                    onChanged: (value) => selectedStatus.value = value,
                  ));
            }),
            Obx(() => RadioListTile<RequestStatus?>(
                  title: const Text('ALL'),
                  value: null,
                  groupValue: selectedStatus.value,
                  onChanged: (value) => selectedStatus.value = value,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Apply',
            onPressed: () {
              Get.back();
              pagingController.refresh();
            },
          ),
        ],
      ),
    );
  }
}
