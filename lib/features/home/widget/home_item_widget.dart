import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/home_item_model.dart';

class HomeItemWidget extends StatelessWidget {
  final HomeItemModel item;
  final VoidCallback? onTap;
  final Function(ItemStatus)? onStatusChange; // Added this parameter

  const HomeItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onStatusChange, // Added this parameter
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
                    // Item Icon/Image
                    _buildItemIcon(),
                    const SizedBox(width: 12),

                    // Item Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
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
                            item.description,
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

                    // Status Badge
                    _buildStatusBadge(),
                  ],
                ),

                const SizedBox(height: 12),

                // Item Footer
                Row(
                  children: [
                    // Category
                    if (item.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.category!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Priority Indicator
                    if (item.priority > 0) ...[
                      _buildPriorityIndicator(),
                      const SizedBox(width: 8),
                    ],

                    const Spacer(),

                    // Created Date
                    if (item.createdAt != null)
                      Text(
                        _formatDate(item.createdAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),

                // Quick Status Change Actions (Added this section)
                if (onStatusChange != null &&
                    item.status != ItemStatus.completed) ...[
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

  Widget _buildItemIcon() {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
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

  Widget _buildPriorityIndicator() {
    return Row(
      children: List.generate(
        3,
        (index) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color:
                index < item.priority ? _getPriorityColor() : AppColors.border,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Added this method for quick status change actions
  Widget _buildQuickActions() {
    final availableActions = _getAvailableActions();

    if (availableActions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: availableActions.map((action) {
        return OutlinedButton(
          onPressed: () => onStatusChange?.call(action.status),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            side: BorderSide(color: action.color),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action.label,
            style: TextStyle(
              fontSize: 12,
              color: action.color,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Added this method to get available status change actions
  List<QuickAction> _getAvailableActions() {
    switch (item.status) {
      case ItemStatus.pending:
        return [
          QuickAction('Start', ItemStatus.active, AppColors.info),
          QuickAction('Complete', ItemStatus.completed, AppColors.success),
        ];
      case ItemStatus.active:
        return [
          QuickAction('Complete', ItemStatus.completed, AppColors.success),
          QuickAction('Pause', ItemStatus.pending, AppColors.warning),
        ];
      case ItemStatus.completed:
        return []; // No actions for completed items
      case ItemStatus.cancelled:
        return [
          QuickAction('Restart', ItemStatus.pending, AppColors.info),
        ];
    }
  }

  Color _getStatusColor() {
    switch (item.status) {
      case ItemStatus.active:
        return AppColors.success;
      case ItemStatus.pending:
        return AppColors.warning;
      case ItemStatus.completed:
        return AppColors.info;
      case ItemStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (item.status) {
      case ItemStatus.active:
        return Icons.play_circle_outline;
      case ItemStatus.pending:
        return Icons.pending_outlined;
      case ItemStatus.completed:
        return Icons.check_circle_outline;
      case ItemStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case ItemStatus.active:
        return 'Active';
      case ItemStatus.pending:
        return 'Pending';
      case ItemStatus.completed:
        return 'Completed';
      case ItemStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getPriorityColor() {
    if (item.priority >= 3) return AppColors.error;
    if (item.priority >= 2) return AppColors.warning;
    return AppColors.info;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Added this class for quick actions
class QuickAction {
  final String label;
  final ItemStatus status;
  final Color color;

  const QuickAction(this.label, this.status, this.color);
}
