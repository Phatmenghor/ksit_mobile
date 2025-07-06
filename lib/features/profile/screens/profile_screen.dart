// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/config/app_config.dart';
import 'package:ksit_mobile/core/constants/app_constants.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/features/profile/widgets/profile_menu_item_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: _buildAppBar(profileController),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // View Profile Card
                  _buildViewProfileCard(context),

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
                          onTap: () => {
                            context.push(AppRoutes.editProfileRoute),
                          },
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
                          onTap: () => {
                            context.push(AppRoutes.configurationRoute),
                          },
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
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileController controller) {
    return AppBar(
      backgroundColor: AppColors.primary,
      title: Obx(() => Row(
            children: [
              // Profile Avatar
              _buildProfileAvatar(controller),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.normal,
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
          )),
      toolbarHeight: 80, // Adjust height as needed
    );
  }

  Widget _buildProfileAvatar(ProfileController controller) {
    final imageUrl = controller.currentUserProfileUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(AppConfig.baseImageUrl + imageUrl),
        backgroundColor: Colors.white,
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
  }

  Widget _buildViewProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.profileViewRoute);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
    return ProfileMenuItemWidget(
      icon: icon,
      title: title,
      onTap: onTap,
      titleColor: titleColor,
      iconColor: iconColor,
      iconUrl: iconUrl,
      showArrow: showArrow,
    );
  }
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

Future<void> _handleAboutKSIT() async {
  try {
    final Uri url = Uri.parse(AppConstants.websiteKSIT);

    // Check if URL can be launched
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens in external browser
      );
    } else {
      // Fallback: try to launch in any available way
      await launchUrl(url);
    }
  } catch (e) {
    // Handle error if URL cannot be opened
    ToastUtils.showError(
        'Unable to open KSIT website. Please check your internet connection.');
  }
}

void _handleLogout(ProfileController controller) {
  controller.logout();
}
