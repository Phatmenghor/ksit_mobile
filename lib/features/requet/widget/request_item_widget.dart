import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/request_model.dart';

class RequestItemWidget extends StatelessWidget {
  final RequestModel request;
  final VoidCallback? onTap;
  final Function(RequestStatus)? onStatusChange;

  const RequestItemWidget({
    super.key,
    required this.request,
    this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Request Icon
                    _buildRequestIcon(),
                    const SizedBox(width: 12),

                    // Request Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Priority Badge
                    _buildPriorityBadge(),
                  ],
                ),

                const SizedBox(height: 12),

                // Request Footer
                Row(
                  children: [
                    // Status Badge
                    _buildStatusBadge(),

                    const SizedBox(width: 8),

                    // Type
                    if (request.type != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          request.type!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    const Spacer(),

                    // Due Date or Created Date
                    if (request.dueDate != null)
                      _buildDateChip(
                        'Due: ${_formatDate(request.dueDate!)}',
                        _isOverdue(request.dueDate!)
                            ? AppColors.error
                            : AppColors.warning,
                      )
                    else if (request.createdAt != null)
                      Text(
                        _formatDate(request.createdAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),

                // Quick Actions
                if (onStatusChange != null &&
                    request.status != RequestStatus.completed) ...[
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getStatusIcon(),
        color: _getStatusColor(),
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: 12,
            color: _getPriorityColor(),
          ),
          const SizedBox(width: 2),
          Text(
            request.priority.name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getPriorityColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final availableActions = _getAvailableActions();

    if (availableActions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: availableActions.map((action) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: OutlinedButton(
            onPressed: () => onStatusChange?.call(action.status),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              side: BorderSide(color: action.color),
            ),
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                color: action.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<QuickAction> _getAvailableActions() {
    switch (request.status) {
      case RequestStatus.pending:
        return [
          QuickAction('Start', RequestStatus.inProgress, AppColors.info),
          QuickAction('Cancel', RequestStatus.cancelled, AppColors.error),
        ];
      case RequestStatus.inProgress:
        return [
          QuickAction('Complete', RequestStatus.completed, AppColors.success),
          QuickAction('Cancel', RequestStatus.cancelled, AppColors.error),
        ];
      case RequestStatus.completed:
      case RequestStatus.cancelled:
        return [];
    }
  }

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.pending:
        return AppColors.warning;
      case RequestStatus.inProgress:
        return AppColors.info;
      case RequestStatus.completed:
        return AppColors.success;
      case RequestStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case RequestStatus.pending:
        return Icons.pending_outlined;
      case RequestStatus.inProgress:
        return Icons.play_circle_outline;
      case RequestStatus.completed:
        return Icons.check_circle_outline;
      case RequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getPriorityColor() {
    switch (request.priority) {
      case RequestPriority.low:
        return AppColors.success;
      case RequestPriority.medium:
        return AppColors.info;
      case RequestPriority.high:
        return AppColors.warning;
      case RequestPriority.urgent:
        return AppColors.error;
    }
  }

  IconData _getPriorityIcon() {
    switch (request.priority) {
      case RequestPriority.low:
        return Icons.keyboard_arrow_down;
      case RequestPriority.medium:
        return Icons.remove;
      case RequestPriority.high:
        return Icons.keyboard_arrow_up;
      case RequestPriority.urgent:
        return Icons.priority_high;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool _isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }
}

class QuickAction {
  final String label;
  final RequestStatus status;
  final Color color;

  const QuickAction(this.label, this.status, this.color);
}
