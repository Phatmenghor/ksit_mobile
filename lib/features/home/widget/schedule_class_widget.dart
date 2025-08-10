// lib/features/home/widget/schedule_class_widget.dart
import 'package:flutter/material.dart';
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
                  Image.asset(
                    AppImages.logoSchool,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
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
                  Row(
                    children: [
                      Image.asset(
                        AppImages.person,
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.teacher?.displayName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Location Info using displayName from model
                  Row(
                    children: [
                      Image.asset(
                        AppImages.pin,
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.room?.displayName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
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
        ),
      ),
    );
  }
}
