import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/features/home/controllers/schedule_detail_controller.dart';
import 'package:ksit_mobile/features/home/models/schedule_models.dart';
import 'package:ksit_mobile/shared/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

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

            // Course title
            Text(
              '${schedule.course?.nameKH ?? 'N/A'} - ${schedule.course?.credit ?? 0}(${schedule.course?.theory ?? 0},${schedule.course?.execute ?? 0},${schedule.course?.apply ?? 0})',
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
              'Class ${schedule.classes?.code ?? 'N/A'}',
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
          _buildDetailRow('Day', schedule.dayDisplayName ?? 'N/A'),
          _buildDetailRow('Instructor', schedule.teacher?.displayName ?? 'N/A'),
          if (schedule.teacher?.email != null)
            _buildDetailRow('Instructor Email', schedule.teacher!.email!),
          _buildDetailRow('Room', schedule.room?.name ?? 'N/A'),
          _buildDetailRow(
              'Time', _formatTimeRange(schedule.startTime, schedule.endTime)),
          _buildDetailRow('Duration',
              _calculateDuration(schedule.startTime, schedule.endTime)),
          _buildDetailRow('Academy Year',
              '${schedule.academyYear ?? schedule.classes?.academyYear ?? 'N/A'}'),
          _buildDetailRow('Semester', schedule.semester?.displayName ?? 'N/A'),
          _buildDetailRow(
              'Year Level',
              _formatYearLevel(
                  schedule.yearLevel ?? schedule.classes?.yearLevel)),
          if (schedule.classes?.degree != null)
            _buildDetailRow('Degree', _formatDegree(schedule.classes!.degree!)),
          _buildDetailRow(
              'Department',
              schedule.classes?.major?.department?.name ??
                  schedule.course?.department?.name ??
                  'N/A'),
          _buildDetailRow('Major', schedule.classes?.major?.name ?? 'N/A'),
          _buildDetailRow('Course Code', schedule.course?.code ?? 'N/A'),
          _buildDetailRow('Course Name (EN)', schedule.course?.nameEn ?? 'N/A'),
          _buildDetailRow('Course Name (KH)', schedule.course?.nameKH ?? 'N/A'),
          _buildDetailRow('Credits', '${schedule.course?.credit ?? 0}'),
          _buildDetailRow('Credit Structure',
              '${schedule.course?.theory ?? 0}.${schedule.course?.execute ?? 0}.${schedule.course?.apply ?? 0}'),
          _buildDetailRow(
              'Total Hours', '${schedule.course?.totalHour ?? 0} hours'),
          if (schedule.course?.subject?.name != null)
            _buildDetailRow('Subject', schedule.course!.subject!.name!),
          if (schedule.course?.description != null &&
              schedule.course!.description!.isNotEmpty)
            _buildDetailRow('Description', schedule.course!.description!),
          if (schedule.course?.purpose != null &&
              schedule.course!.purpose!.isNotEmpty)
            _buildDetailRow('Purpose', schedule.course!.purpose!),
          if (schedule.course?.expectedOutcome != null &&
              schedule.course!.expectedOutcome!.isNotEmpty)
            _buildDetailRow(
                'Expected Outcome', schedule.course!.expectedOutcome!),
          _buildDetailRow('Status', _formatStatus(schedule.status)),
          if (schedule.semester?.startDate != null &&
              schedule.semester?.endDate != null)
            _buildDetailRow('Semester Period',
                '${schedule.semester!.startDate!} to ${schedule.semester!.endDate!}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return 'N/A';

    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final end = DateFormat('HH:mm').parse(endTime);

      final startFormatted = DateFormat('h:mm a').format(start);
      final endFormatted = DateFormat('h:mm a').format(end);

      return '$startFormatted - $endFormatted';
    } catch (e) {
      return '$startTime - $endTime';
    }
  }

  String _calculateDuration(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return 'N/A';

    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final end = DateFormat('HH:mm').parse(endTime);

      final duration = end.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatYearLevel(String? yearLevel) {
    if (yearLevel == null) return 'N/A';

    switch (yearLevel.toUpperCase()) {
      case 'FIRST_YEAR':
        return 'First Year';
      case 'SECOND_YEAR':
        return 'Second Year';
      case 'THIRD_YEAR':
        return 'Third Year';
      case 'FOURTH_YEAR':
        return 'Fourth Year';
      default:
        return yearLevel;
    }
  }

  String _formatDegree(String degree) {
    switch (degree.toUpperCase()) {
      case 'BACHELOR':
        return 'Bachelor Degree';
      case 'MASTER':
        return 'Master Degree';
      case 'DOCTORATE':
        return 'Doctorate Degree';
      case 'ASSOCIATE':
        return 'Associate Degree';
      default:
        return degree;
    }
  }

  String _formatStatus(String? status) {
    if (status == null) return 'N/A';

    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'INACTIVE':
        return 'Inactive';
      case 'DELETED':
        return 'Deleted';
      default:
        return status;
    }
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
