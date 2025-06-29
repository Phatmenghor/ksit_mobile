import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/features/home/controllers/schedule_detail_controller.dart';
import 'package:ksit_mobile/shared/widgets/loading_widget.dart';

class ScheduleDetailScreen extends StatelessWidget {
  final int scheduleId;

  const ScheduleDetailScreen({
    super.key,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(ScheduleDetailController(scheduleId: scheduleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(
            message: 'Loading schedule details...',
            overlay: false,
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        final schedule = controller.schedule.value;
        if (schedule == null) {
          return const Center(
            child: Text('Schedule not found'),
          );
        }

        return Column(
          children: [
            // Custom Header with green background
            _buildCustomHeader(context, schedule),

            // White content area
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow('Day', schedule.dayDisplayName),
                      _buildDetailRow(
                          'Instructor', schedule.teacher?.displayName ?? 'N/A'),
                      _buildDetailRow('Room', schedule.room?.name ?? 'N/A'),
                      _buildDetailRow('Time',
                          '${schedule.startTime ?? ''} - ${schedule.endTime ?? ''}'),
                      _buildDetailRow(
                          'Academy Year', '${schedule.academyYear ?? 'N/A'}'),
                      _buildDetailRow(
                          'Semester', schedule.semester?.displayName ?? 'N/A'),
                      _buildDetailRow(
                          'Year Level', schedule.yearLevel ?? 'N/A'),
                      _buildDetailRow('Department',
                          schedule.classes?.major?.department?.name ?? 'N/A'),
                      _buildDetailRow(
                          'Major', schedule.classes?.major?.name ?? 'N/A'),
                      _buildDetailRow(
                          'Credits', '${schedule.course?.credit ?? 0}'),
                      _buildDetailRow('Credit Structure',
                          '${schedule.course?.theory ?? 0}.${schedule.course?.execute ?? 0}.${schedule.course?.apply ?? 0}'),
                      _buildDetailRow(
                          'Total Hours', '${schedule.course?.totalHour ?? 0}'),
                      if (schedule.course?.description != null)
                        _buildDetailRow(
                            'Description', schedule.course!.description!),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCustomHeader(BuildContext context, schedule) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF024D3E), // Darker green at top
            Color(0xFF036B56), // Lighter green at bottom
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // App bar with back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Class Detail',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    AppImages.logoSchool,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Course title
              Text(
                schedule.course?.nameEn ?? 'Course Name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Class code
              Text(
                'Class ${schedule.classes?.code ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF757575),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ScheduleDetailController controller) {
    return Column(
      children: [
        // Header even for error state
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF024D3E),
                Color(0xFF036B56),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Class Detail',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Error content
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
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
                      'Error Loading Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: controller.loadScheduleDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
