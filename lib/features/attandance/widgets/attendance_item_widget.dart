// lib/features/attendance/widgets/attendance_item_widget.dart
import 'package:flutter/material.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/features/attandance/models/attendance_models.dart';

class AttendanceItemWidget extends StatelessWidget {
  final AttendanceHistoryModel attendance;
  final VoidCallback? onTap;

  const AttendanceItemWidget({
    super.key,
    required this.attendance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
                  // Status Badge
                  _buildStatusBadge(),
                  const SizedBox(width: 8),
                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.displayCourseName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${attendance.identifyNumber ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date
                  Text(
                    attendance.displayDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Row (Updated to show attendance type with colors)
              Row(
                children: [
                  // Attendance Type with color
                  _buildInfoChip(
                    icon: _getAttendanceTypeIcon(attendance.attendanceType),
                    label: attendance.displayAttendanceType,
                    color:
                        _getAttendanceTypeColor(attendance.attendanceTypeColor),
                  ),
                  const SizedBox(width: 8),
                  // Teacher Info
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.person_outline,
                      label: attendance.displayTeacherName,
                    ),
                  ),
                ],
              ),

              if (attendance.recordedTime != null) ...[
                const SizedBox(height: 8),
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: 'Recorded: ${attendance.displayRecordedTime}',
                ),
              ],

              if (attendance.comment != null &&
                  attendance.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Comment: ${attendance.comment}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;

    switch (attendance.statusColor) {
      case 'success':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case 'error':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case 'warning':
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case 'info':
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      default:
        backgroundColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        attendance.displayStatus.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.border).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color ?? AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAttendanceTypeIcon(String? attendanceType) {
    switch (attendanceType?.toUpperCase()) {
      case 'NONE':
        return Icons.check_circle_outline;
      case 'LATE':
        return Icons.schedule_outlined;
      case 'PERMISSION':
        return Icons.verified_user_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getAttendanceTypeColor(String colorType) {
    switch (colorType) {
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
