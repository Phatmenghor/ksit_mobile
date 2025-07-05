// lib/features/home/screens/schedule_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/features/home/controllers/schedule_detail_controller.dart';
import 'package:ksit_mobile/features/home/models/schedule_models.dart';
import 'package:ksit_mobile/shared/widgets/loading_widget.dart';

// Import the new utils
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/ui_utils.dart';

class ScheduleDetailScreen extends StatelessWidget {
  final int scheduleId;

  const ScheduleDetailScreen({
    super.key,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    // Remove any existing controller with this tag first
    final tag = 'schedule_detail_$scheduleId';
    if (Get.isRegistered<ScheduleDetailController>(tag: tag)) {
      Get.delete<ScheduleDetailController>(tag: tag);
    }

    final controller = Get.put(
      ScheduleDetailController(scheduleId: scheduleId),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(right: 52),
          child: Text(
            'Class Detail',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: const Color(0xFF024D3E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
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

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(schedule),
              _buildDetailsSection(schedule),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection(ScheduleModel schedule) {
    return Container(
      color: AppColors.primary,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AppImages.logoSchool,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // Course title using FormatUtils
            Text(
              schedule.course?.displayWithCredits ?? 'N/A',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Class code
            Text(
              'Class ${schedule.classes?.displayCode ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ScheduleModel schedule) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Use UIUtils.buildDetailRow for all detail rows
          UIUtils.buildDetailRow(
            label: 'Day',
            value: schedule.dayDisplayName,
          ),
          UIUtils.buildDetailRow(
            label: 'Instructor',
            value: schedule.teacher?.displayName ?? 'N/A',
          ),
          if (schedule.teacher?.email != null)
            UIUtils.buildDetailRow(
              label: 'Instructor Email',
              value: schedule.teacher!.email!,
            ),
          UIUtils.buildDetailRow(
            label: 'Room',
            value: schedule.room?.displayName ?? 'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Time',
            value: FormatUtils.formatTimeRange(
                schedule.startTime, schedule.endTime),
          ),
          UIUtils.buildDetailRow(
            label: 'Duration',
            value: FormatUtils.calculateDuration(
                schedule.startTime, schedule.endTime),
          ),
          UIUtils.buildDetailRow(
            label: 'Academy Year',
            value:
                '${schedule.academyYear ?? schedule.classes?.academyYear ?? 'N/A'}',
          ),
          UIUtils.buildDetailRow(
            label: 'Semester',
            value: schedule.semester?.displayName ?? 'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Year Level',
            value: FormatUtils.formatYearLevel(
                schedule.yearLevel ?? schedule.classes?.yearLevel),
          ),
          if (schedule.classes?.degree != null)
            UIUtils.buildDetailRow(
              label: 'Degree',
              value: FormatUtils.formatDegree(schedule.classes!.degree!),
            ),
          UIUtils.buildDetailRow(
            label: 'Department',
            value: schedule.classes?.major?.department?.displayName ??
                schedule.course?.department?.displayName ??
                'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Major',
            value: schedule.classes?.major?.displayName ?? 'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Course Code',
            value: schedule.course?.code ?? 'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Course Name (EN)',
            value: schedule.course?.nameEn ?? 'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Course Name (KH)',
            value: schedule.course?.nameKH ?? 'N/A',
          ),
          UIUtils.buildDetailRow(
            label: 'Credits',
            value: '${schedule.course?.credit ?? 0}',
          ),
          UIUtils.buildDetailRow(
            label: 'Credit Structure',
            value: FormatUtils.formatCreditStructure(
              schedule.course?.theory,
              schedule.course?.execute,
              schedule.course?.apply,
            ),
          ),
          UIUtils.buildDetailRow(
            label: 'Total Hours',
            value: '${schedule.course?.totalHour ?? 0} hours',
          ),
          if (schedule.course?.subject?.displayName != null)
            UIUtils.buildDetailRow(
              label: 'Subject',
              value: schedule.course!.subject!.displayName,
            ),
          if (schedule.course?.description != null &&
              schedule.course!.description!.isNotEmpty)
            UIUtils.buildDetailRow(
              label: 'Description',
              value: schedule.course!.description!,
            ),
          if (schedule.course?.purpose != null &&
              schedule.course!.purpose!.isNotEmpty)
            UIUtils.buildDetailRow(
              label: 'Purpose',
              value: schedule.course!.purpose!,
            ),
          if (schedule.course?.expectedOutcome != null &&
              schedule.course!.expectedOutcome!.isNotEmpty)
            UIUtils.buildDetailRow(
              label: 'Expected Outcome',
              value: schedule.course!.expectedOutcome!,
            ),
          UIUtils.buildDetailRow(
            label: 'Status',
            value: FormatUtils.formatStatus(schedule.status),
          ),
          if (schedule.semester?.startDate != null &&
              schedule.semester?.endDate != null)
            UIUtils.buildDetailRow(
              label: 'Semester Period',
              value:
                  '${schedule.semester!.startDate!} to ${schedule.semester!.endDate!}',
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ScheduleDetailController controller) {
    return Center(
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
    );
  }
}
