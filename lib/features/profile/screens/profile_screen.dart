// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/core/config/app_config.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/toast_utils.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        return Column(
          children: [
            // Header Section
            _buildHeader(profileController),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // View Profile Card
                          _buildViewProfileCard(),

                          const SizedBox(height: 16),

                          // Menu Items
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  icon: Icons.person_outline,
                                  title: 'Edit Profile',
                                  onTap: () =>
                                      _handleEditProfile(profileController),
                                ),
                                _buildMenuItem(
                                  icon: Icons.description_outlined,
                                  title: 'Transcript',
                                  onTap: () => _handleTranscript(),
                                ),
                                _buildMenuItem(
                                  icon: Icons.history,
                                  title: 'Attendance History',
                                  onTap: () => _handleAttendanceHistory(),
                                ),
                                _buildMenuItem(
                                  icon: Icons.lock_outline,
                                  title: 'Change Password',
                                  onTap: () => _handleChangePassword(),
                                ),
                                _buildMenuItem(
                                  icon: Icons.info_outline,
                                  title: 'About KSIT',
                                  iconUrl:
                                      'assets/images/logo_screen.png', // Using your app logo
                                  onTap: () => _handleAboutKSIT(),
                                ),
                                _buildMenuItem(
                                  icon: Icons.settings_outlined,
                                  title: 'Configuration',
                                  onTap: () => _handleConfiguration(),
                                ),
                                _buildMenuItem(
                                  icon: Icons.logout,
                                  title: 'Logout',
                                  titleColor: AppColors.error,
                                  iconColor: AppColors.error,
                                  showArrow: false,
                                  onTap: () => _handleLogout(profileController),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          // Profile Avatar

          Obx(() {
            final imageUrl = controller.currentUserProfileUrl;

            print('Profile Image URL: $imageUrl');

            if (imageUrl != null && imageUrl.isNotEmpty) {
              return CircleAvatar(
                radius: 22,
                backgroundImage:
                    NetworkImage(AppConfig.baseImageUrl + imageUrl),
                backgroundColor: Colors.white,
                // Add error handling for network images
                child: null,
                onBackgroundImageError: (exception, stackTrace) {
                  // If image fails to load, show default icon
                },
              );
            } else {
              return const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 28,
                ),
              );
            }
          }),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  controller.currentUserDisplayName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.white,
        //border all
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person,
            size: 20,
            color: AppColors.primary,
          ),
          SizedBox(height: 8),
          Text(
            'View Profile',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    String? iconUrl,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: showArrow
                  ? const Border(
                      bottom: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon
                if (iconUrl != null)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset(
                      iconUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          icon,
                          size: 24,
                          color: iconColor ?? AppColors.primary,
                        );
                      },
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? AppColors.primary,
                  ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Action Handlers - Add your logic here
  void _handleEditProfile(ProfileController controller) {
    ToastUtils.showInfo('Edit Profile clicked');
    // TODO: Add edit profile logic here
    // Example: Get.toNamed('/edit-profile');
    // Or show a dialog, bottom sheet, etc.
  }

  void _handleTranscript() {
    ToastUtils.showInfo('Transcript clicked');
    // TODO: Add transcript logic here
    // Example: Get.toNamed('/transcript');
    // Or open a document viewer, etc.
  }

  void _handleAttendanceHistory() {
    ToastUtils.showInfo('Attendance History clicked');
    // TODO: Add attendance history logic here
    // Example: Get.toNamed('/attendance-history');
    // Or show attendance data, etc.
  }

  void _handleChangePassword() {
    ToastUtils.showInfo('Change Password clicked');
    // TODO: Add change password logic here
    // Example: _showChangePasswordDialog();
    // Or navigate to change password screen
  }

  void _handleAboutKSIT() {
    ToastUtils.showInfo('About KSIT clicked');
    // TODO: Add about KSIT logic here
    // Example: Get.toNamed('/about-ksit');
    // Or show information dialog
  }

  void _handleConfiguration() {
    ToastUtils.showInfo('Configuration clicked');
    // TODO: Add configuration logic here
    // Example: Get.toNamed('/settings');
    // Or show settings screen
  }

  void _handleLogout(ProfileController controller) {
    ToastUtils.showInfo('Logout clicked');
    // TODO: Add logout logic here
    // Example: controller.logout();
    // Or show confirmation dialog
  }
}
