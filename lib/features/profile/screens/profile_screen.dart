import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: profileController.editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: profileController.openSettings,
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const LoadingWidget(
            message: 'Loading profile...',
            overlay: false,
          );
        }

        return RefreshIndicator(
          onRefresh: profileController.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(profileController),

                const SizedBox(height: 24),

                // Profile Stats
                _buildProfileStats(profileController),

                const SizedBox(height: 24),

                // Menu Items
                _buildMenuSection(profileController),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutSection(profileController),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: controller.user.value?.avatar != null
                    ? NetworkImage(controller.user.value!.avatar!)
                    : null,
                child: controller.user.value?.avatar == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            controller.user.value?.name ?? 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            controller.user.value?.email ?? 'user@example.com',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),

          // Phone (if available)
          if (controller.user.value?.phone != null) ...[
            const SizedBox(height: 4),
            Text(
              controller.user.value!.phone!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],

          // Role (if available)
          if (controller.user.value?.role != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                controller.user.value!.role!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileStats(ProfileController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Requests',
            controller.totalRequests.value.toString(),
            Icons.request_page_outlined,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            controller.completedRequests.value.toString(),
            Icons.check_circle_outline,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Scans',
            controller.totalScans.value.toString(),
            Icons.qr_code_scanner,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(ProfileController controller) {
    final menuItems = [
      MenuItemData(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        onTap: controller.editProfile,
      ),
      MenuItemData(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Manage notification preferences',
        onTap: controller.openNotificationSettings,
      ),
      MenuItemData(
        icon: Icons.security_outlined,
        title: 'Privacy & Security',
        subtitle: 'Password and security settings',
        onTap: controller.openSecuritySettings,
      ),
      MenuItemData(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: controller.openHelp,
      ),
      MenuItemData(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'App version and information',
        onTap: controller.showAbout,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.iconSecondary,
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutSection(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomButton(
            text: 'Logout',
            onPressed: controller.logout,
            backgroundColor: AppColors.error,
            width: double.infinity,
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            isLoading: controller.isLoggingOut.value,
          ),
          const SizedBox(height: 8),
          Text(
            'Version ${AppConstants.appVersion}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
