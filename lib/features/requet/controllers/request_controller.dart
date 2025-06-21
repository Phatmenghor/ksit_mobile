import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/request_model.dart';

class RequestController extends GetxController {
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

  // Static mock data
  static final List<RequestModel> _mockRequests = [
    RequestModel(
      id: 1,
      title: 'New Feature Request',
      description: 'Add dark mode theme to the application',
      status: RequestStatus.pending,
      priority: RequestPriority.high,
      type: 'Feature',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RequestModel(
      id: 2,
      title: 'Bug Fix Request',
      description: 'Fix login page validation issues',
      status: RequestStatus.inProgress,
      priority: RequestPriority.urgent,
      type: 'Bug',
      assignedTo: 'John Developer',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    RequestModel(
      id: 3,
      title: 'Documentation Update',
      description: 'Update API documentation with new endpoints',
      status: RequestStatus.completed,
      priority: RequestPriority.medium,
      type: 'Documentation',
      assignedTo: 'Jane Writer',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RequestModel(
      id: 4,
      title: 'Performance Optimization',
      description: 'Optimize database queries for faster response times',
      status: RequestStatus.inProgress,
      priority: RequestPriority.high,
      type: 'Enhancement',
      assignedTo: 'Bob Engineer',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    RequestModel(
      id: 5,
      title: 'Security Audit',
      description: 'Perform comprehensive security audit of the system',
      status: RequestStatus.pending,
      priority: RequestPriority.urgent,
      type: 'Security',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      dueDate: DateTime.now().add(const Duration(days: 7)),
    ),
    RequestModel(
      id: 6,
      title: 'UI Improvements',
      description: 'Improve user interface design and user experience',
      status: RequestStatus.cancelled,
      priority: RequestPriority.low,
      type: 'Design',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
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
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      final pageSize = AppConstants.defaultPageSize;
      final startIndex = (pageKey - 1) * pageSize;

      // Filter requests based on selected status
      List<RequestModel> filteredRequests = selectedStatus.value == null
          ? _mockRequests
          : _mockRequests
              .where((request) => request.status == selectedStatus.value)
              .toList();

      final endIndex = startIndex + pageSize;
      List<RequestModel> pageItems;

      if (startIndex >= filteredRequests.length) {
        pageItems = [];
      } else {
        pageItems = filteredRequests.sublist(
          startIndex,
          endIndex > filteredRequests.length
              ? filteredRequests.length
              : endIndex,
        );
      }

      final isLastPage = endIndex >= filteredRequests.length;

      if (isLastPage) {
        pagingController.appendLastPage(pageItems);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(pageItems, nextPageKey);
      }

      LoggerUtils.info(
          'Page $pageKey loaded with ${pageItems.length} requests');
    } catch (e) {
      LoggerUtils.error('Error fetching page $pageKey', e);
      pagingController.error = e.toString();
    }
  }

  Future<void> refreshRequests() async {
    try {
      pagingController.refresh();
      LoggerUtils.info('Requests refreshed successfully');
    } catch (e) {
      LoggerUtils.error('Error refreshing requests', e);
    }
  }

  void setStatusFilter(RequestStatus? status) {
    selectedStatus.value = status;
    pagingController.refresh();
    LoggerUtils.info('Status filter set to: ${status?.name ?? 'All'}');
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
                    if (request.assignedTo != null)
                      _buildDetailRow('Assigned To', request.assignedTo!),
                    if (request.createdAt != null)
                      _buildDetailRow(
                          'Created', _formatDateTime(request.createdAt!)),
                    if (request.updatedAt != null)
                      _buildDetailRow(
                          'Updated', _formatDateTime(request.updatedAt!)),
                    if (request.dueDate != null)
                      _buildDetailRow(
                          'Due Date', _formatDateTime(request.dueDate!)),
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
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Find and update the request in mock data
      final index = _mockRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _mockRequests[index] = request.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      Fluttertoast.showToast(
        msg: 'Status updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      pagingController.refresh();
      LoggerUtils.info(
          'Request ${request.id} status updated to ${newStatus.name}');
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
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Create new request and add to mock data
      final newRequest = RequestModel(
        id: _mockRequests.length + 1,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        status: RequestStatus.pending,
        priority: selectedPriority.value,
        type: 'General',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _mockRequests.insert(0, newRequest);

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
      LoggerUtils.info('New request created: ${newRequest.title}');
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
