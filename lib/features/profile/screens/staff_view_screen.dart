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
                      label: "អត្តលេខនិស្សិត",
                      value: staffProfile?.identifyNumber ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "នាមត្រកូល និងនាម",
                      value: staffProfile?.khmerFirstName != null ||
                              staffProfile?.khmerLastName != null
                          ? '${staffProfile?.khmerFirstName ?? ""} ${staffProfile?.khmerLastName ?? ""}'
                              .trim()
                          : "N/A",
                    ),
                    DisplayRowWidget(
                      label: "អក្សរឡាតាំង",
                      value: staffProfile?.englishFirstName != null ||
                              staffProfile?.englishLastName != null
                          ? '${staffProfile?.englishFirstName ?? ""} ${staffProfile?.englishLastName ?? ""}'
                              .trim()
                          : "N/A",
                    ),
                    DisplayRowWidget(
                      label: "ថ្ងៃខែឆ្នាំកំណើត",
                      value: staffProfile?.dateOfBirth ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "ភេទ",
                      value: staffProfile?.gender ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "ជនជាតិ",
                      value: staffProfile?.ethnicity ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "សញ្ជាតិ",
                      value: staffProfile?.nationality ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "ទីកន្លែងកំណើត",
                      value: staffProfile?.placeOfBirth ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "អាសយដ្ឋានបច្ចុប្បន្ន",
                      value: staffProfile?.currentAddress ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "លេខទូរស័ព្ទ",
                      value: staffProfile?.phoneNumber ?? "N/A",
                    ),
                    DisplayRowWidget(
                      label: "អុីម៉ែល",
                      value: staffProfile?.email ?? "N/A",
                    ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Name
              Text(
                staffProfile?.displayName ?? "N/A",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
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
      final imageUrl = controller.studentProfile.value?.profileUrl;
      final hasImage = imageUrl != null && imageUrl.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 32,
          backgroundColor:
              hasImage ? Colors.white : AppColors.primary.withOpacity(0.1),
          backgroundImage: hasImage
              ? NetworkImage(AppConfig.baseImageUrl + imageUrl!)
              : null,
          onBackgroundImageError: hasImage
              ? (exception, stackTrace) {
                  debugPrint('Image failed to load: $exception');
                }
              : null,
          child: !hasImage
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                )
              : null,
        ),
      );
    });
  }
}
