import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../shared/models/user/user_model.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoggingOut = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxInt totalRequests = 0.obs;
  final RxInt completedRequests = 0.obs;
  final RxInt totalScans = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadProfileStats();
  }

  void _loadUserData() {
    user.value = _authController.currentUser.value;
  }

  Future<void> _loadProfileStats() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.profileEndpoint}/stats',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        totalRequests.value = data['totalRequests'] ?? 0;
        completedRequests.value = data['completedRequests'] ?? 0;
        totalScans.value = data['totalScans'] ?? 0;
      }
    } catch (e) {
      LoggerUtils.error('Error loading profile stats', e);
      // Set default values
      totalRequests.value = 25;
      completedRequests.value = 18;
      totalScans.value = 42;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await Future.wait([
      _loadUserProfile(),
      _loadProfileStats(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.profileEndpoint,
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data!['user'] ?? response.data!;
        user.value = UserModel.fromJson(userData);

        // Update auth controller's user data
        _authController.currentUser.value = user.value;
      }
    } catch (e) {
      LoggerUtils.error('Error loading user profile', e);
    }
  }

  void editProfile() {
    // TODO: Navigate to edit profile screen
    Get.snackbar(
      'Edit Profile',
      'Edit profile functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openSettings() {
    // TODO: Navigate to settings screen
    Get.snackbar(
      'Settings',
      'Settings functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openNotificationSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Push Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
            ),
            ListTile(
              title: const Text('Email Notifications'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
            ),
            ListTile(
              title: const Text('Sound'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void openSecuritySettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Change Password'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric Authentication'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: Icon(Icons.visibility_off_outlined),
              title: Text('Privacy Settings'),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void openHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('FAQ'),
              subtitle: Text('Frequently asked questions'),
            ),
            ListTile(
              leading: Icon(Icons.contact_support),
              title: Text('Contact Support'),
              subtitle: Text('Get help from our team'),
            ),
            ListTile(
              leading: Icon(Icons.bug_report_outlined),
              title: Text('Report a Bug'),
              subtitle: Text('Help us improve the app'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showAbout() {
    showAboutDialog(
      context: Get.context!,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese:
          '© 2024 ${AppConstants.appName}. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A modern Flutter application built with GetX, Go Router, and Firebase.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'Features include authentication, real-time notifications, QR code scanning, and request management.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoggingOut.value = true;
        await _authController.logout();
      }
    } catch (e) {
      LoggerUtils.error('Error during logout', e);
      Fluttertoast.showToast(
        msg: 'Error occurred during logout',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }
}
