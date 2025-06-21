import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';
import 'package:ksit_mobile/core/constants/app_constants.dart';
import 'package:ksit_mobile/features/home/controllers/home_controller.dart';
import 'package:ksit_mobile/features/home/models/home_item_model.dart';
import 'package:ksit_mobile/shared/widgets/custom_text_field.dart';

class HomeFilterWidget extends StatelessWidget {
  const HomeFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            hint: 'Search items...',
            prefixIcon: const Icon(Icons.search),
            onChanged: controller.setSearchQuery,
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 40,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: controller.selectedStatus.value == null,
                      onTap: () => controller.setStatusFilter(null),
                    ),
                    _FilterChip(
                      label: 'Active',
                      isSelected:
                          controller.selectedStatus.value == ItemStatus.active,
                      onTap: () =>
                          controller.setStatusFilter(ItemStatus.active),
                    ),
                    _FilterChip(
                      label: 'Pending',
                      isSelected:
                          controller.selectedStatus.value == ItemStatus.pending,
                      onTap: () =>
                          controller.setStatusFilter(ItemStatus.pending),
                    ),
                    _FilterChip(
                      label: 'Completed',
                      isSelected: controller.selectedStatus.value ==
                          ItemStatus.completed,
                      onTap: () =>
                          controller.setStatusFilter(ItemStatus.completed),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}
