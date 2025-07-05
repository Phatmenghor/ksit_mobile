// lib/features/profile/screens/profile_view_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/config/app_config.dart';
import 'package:ksit_mobile/features/home/widget/diaplay_row_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../controllers/profile_controller.dart';

class StaffViewScreen extends StatelessWidget {
  const StaffViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final staffProfile = profileController.staffProfile.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const LoadingWidget(
            message: '',
            overlay: false,
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Profile Image and Basic Info
              _buildHeaderSection(),

              // Profile Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ព័ត៌មានផ្ទាល់ខ្លួន',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Divider(
                      color: AppColors.border,
                      thickness: 0.5,
                    ),

                    // Personal Information
                    DisplayRowWidget(
                        label: "នាមត្រកូល និងនាមខ្លួន",
                        value:
                            '${staffProfile?.khmerFirstName ?? ""} ${staffProfile?.khmerLastName ?? "N/A"}'),
                    DisplayRowWidget(
                        label: "ជាអក្សរឡាតាំង",
                        value:
                            '${staffProfile?.englishFirstName ?? ""} ${staffProfile?.englishLastName ?? "N/A"}'),
                    DisplayRowWidget(
                        label: "ថ្ងៃខែឆ្នាំកំណើត",
                        value: staffProfile?.dateOfBirth ?? "N/A"),

                    DisplayRowWidget(
                        label: "អត្តលេខនិស្សិត",
                        value: staffProfile?.identifyNumber ?? "N/A"),
                    DisplayRowWidget(
                        label: "ភេទ", value: staffProfile?.gender ?? "N/A"),
                    DisplayRowWidget(
                        label: "លេខទូរស័ព្ទ",
                        value: staffProfile?.phoneNumber ?? "N/A"),
                    DisplayRowWidget(
                        label: "អ៊ីម៊ែល", value: staffProfile?.email ?? "N/A"),
                    DisplayRowWidget(
                        label: "ទីកន្លែងកំណើត",
                        value: staffProfile?.placeOfBirth ?? "N/A"),
                    DisplayRowWidget(
                        label: "អាសយដ្ឋានបច្ចុប្បន្ន",
                        value: staffProfile?.currentAddress ?? "N/A"),
                    DisplayRowWidget(
                        label: "ជនជាតិ",
                        value: staffProfile?.ethnicity ?? "N/A"),
                    DisplayRowWidget(
                        label: "សញ្ជាតិ",
                        value: staffProfile?.nationality ?? "N/A"),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection() {
    final controller = Get.find<ProfileController>();
    final staffProfile = controller.staffProfile.value;
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Image

              _buildProfileAvatar(),

              const SizedBox(height: 16),

              // Name
              Text(
                staffProfile?.displayName ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  'ID: ${staffProfile?.identifyNumber ?? "N/A"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      final imageUrl = controller.staffProfile.value?.profileUrl;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(AppConfig.baseImageUrl + imageUrl),
          backgroundColor: Colors.white,
          onBackgroundImageError: (exception, stackTrace) {
            debugPrint('Image failed to load: $exception');
          },
        );
      } else {
        return const CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: 28,
          ),
        );
      }
    });
  }
}
