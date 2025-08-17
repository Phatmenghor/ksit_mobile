// lib/features/home/widget/schedule_class_widget.dart
import 'package:flutter/material.dart';
import 'package:ksit_mobile/core/config/app_config.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/features/home/models/schedule_models.dart';

class ScheduleClassWidget extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final VoidCallback? onSurveyTap;
  final String? statusText;
  final Color? statusColor;

  const ScheduleClassWidget({
    super.key,
    required this.schedule,
    this.onTap,
    this.onSurveyTap,
    this.statusText,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Course Icon with gradient
                  _buildLogoWidget(),

                  const SizedBox(width: 8),
                  // Course Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class ${schedule.classes?.displayCode ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${schedule.dayDisplayName} (${schedule.timeRange})',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Colors.black.withAlpha(128),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Use course displayWithCredits from model
              Text(
                schedule.course?.displayWithCredits ?? 'N/A',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Text(
                "Semester ${_formatSemester(schedule.semester?.semester)} year ${schedule.semester?.academyYear ?? ""} Year Level ${_formatYearLevel(schedule.yearLevel)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),
              const Divider(
                color: AppColors.border,
                thickness: 0.5,
              ),
              const SizedBox(height: 8),

              // Instructor and Location Row
              Row(
                children: [
                  // Instructor Info using displayName from model
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.person,
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            schedule.teacher?.displayName ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Location Info using displayName from model
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.pin,
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            schedule.room?.displayName ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Survey Button Section (outside of Row, as separate section)
              if (schedule.shouldShowSurveyButton) ...[
                const SizedBox(height: 12),
                const Divider(
                  color: AppColors.border,
                  thickness: 0.5,
                ),
                const SizedBox(height: 8),
                _buildSurveyButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoWidget() {
    final logoUrl = schedule.teacher?.department?.urlLogo;

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        AppConfig.baseImageUrl + logoUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppImages.logoSchool,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    // Fallback to local asset if no URL is provided
    return Image.asset(
      AppImages.logoSchool,
      width: 36,
      height: 36,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSurveyButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onSurveyTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: schedule.surveyStatusColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        icon: Image.asset(
          AppImages.survey,
          width: 16,
          height: 16,
          color: Colors.white,
        ),
        label: Text(
          schedule.surveyButtonText,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _formatSemester(String? semester) {
    if (semester == null) return '';
    return semester.replaceAll('SEMESTER_', '');
  }

  String _formatYearLevel(String? yearLevel) {
    if (yearLevel == null) return '';

    switch (yearLevel) {
      case 'FIRST_YEAR':
        return '1st';
      case 'SECOND_YEAR':
        return '2nd';
      case 'THIRD_YEAR':
        return '3rd';
      case 'FOURTH_YEAR':
        return '4th';
      default:
        return yearLevel.replaceAll('_YEAR', '').replaceAll('_', ' ');
    }
  }
}
