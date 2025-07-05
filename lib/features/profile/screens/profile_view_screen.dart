// lib/features/profile/screens/profile_view_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/config/app_config.dart';
import 'package:ksit_mobile/features/profile/widgets/profile_image_widget.dart';
import 'package:ksit_mobile/features/profile/widgets/profile_info_card_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: profileController.editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: profileController.refreshProfile,
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

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Profile Image and Basic Info
              _buildHeaderSection(profileController),

              // Profile Details
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Personal Information
                    _buildPersonalInformation(profileController),

                    const SizedBox(height: 16),

                    // Academic/Work Information
                    if (profileController.userRole.value == 'STUDENT')
                      _buildStudentAcademicInfo(profileController)
                    else if (profileController.userRole.value == 'STAFF')
                      _buildStaffWorkInfo(profileController),

                    const SizedBox(height: 16),

                    // Contact Information
                    _buildContactInformation(profileController),

                    const SizedBox(height: 16),

                    // Additional Information
                    if (profileController.userRole.value == 'STUDENT')
                      _buildStudentAdditionalInfo(profileController)
                    else if (profileController.userRole.value == 'STAFF')
                      _buildStaffAdditionalInfo(profileController),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection(ProfileController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryAccent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            children: [
              // Profile Image
              ProfileImageWidget(
                imageUrl: controller.hasProfileImage
                    ? '${AppConfig.baseImageUrl}${controller.currentUserProfileUrl}'
                    : null,
                radius: 60,
                placeholder: controller.currentUserDisplayName,
                showEditButton: true,
                onEditPressed: () {
                  // TODO: Implement image picker
                  Get.snackbar(
                    'Coming Soon',
                    'Profile image upload functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.info,
                    colorText: Colors.white,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                controller.currentUserDisplayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Role
              Text(
                controller.currentUserRoleDisplay,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 8),

              // Additional Info (Class/Department)
              if (controller.studentClassInfo != null ||
                  controller.staffDepartmentInfo != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.studentClassInfo ??
                        controller.staffDepartmentInfo ??
                        '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInformation(ProfileController controller) {
    final items = <ProfileInfoItem>[];

    if (controller.userRole.value == 'STUDENT') {
      final student = controller.studentProfile.value;
      if (student != null) {
        items.addAll([
          if (student.englishFirstName != null &&
              student.englishLastName != null)
            ProfileInfoItem.identity(
              label: 'Full Name (English)',
              value: '${student.englishFirstName} ${student.englishLastName}',
            ),
          if (student.khmerFirstName != null && student.khmerLastName != null)
            ProfileInfoItem.identity(
              label: 'Full Name (Khmer)',
              value: '${student.khmerFirstName} ${student.khmerLastName}',
            ),
          if (student.gender != null)
            ProfileInfoItem.identity(
              label: 'Gender',
              value: student.gender!,
            ),
          if (student.dateOfBirth != null)
            ProfileInfoItem.identity(
              label: 'Date of Birth',
              value: student.dateOfBirth!,
            ),
          if (student.nationality != null)
            ProfileInfoItem.identity(
              label: 'Nationality',
              value: student.nationality!,
            ),
          if (student.ethnicity != null)
            ProfileInfoItem.identity(
              label: 'Ethnicity',
              value: student.ethnicity!,
            ),
          if (student.placeOfBirth != null)
            ProfileInfoItem.identity(
              label: 'Place of Birth',
              value: student.placeOfBirth!,
            ),
          if (student.identifyNumber != null)
            ProfileInfoItem.identity(
              label: 'Student ID',
              value: student.identifyNumber!,
            ),
        ]);
      }
    } else if (controller.userRole.value == 'STAFF') {
      final staff = controller.staffProfile.value;
      if (staff != null) {
        items.addAll([
          if (staff.englishFirstName != null && staff.englishLastName != null)
            ProfileInfoItem.identity(
              label: 'Full Name (English)',
              value: '${staff.englishFirstName} ${staff.englishLastName}',
            ),
          if (staff.khmerFirstName != null && staff.khmerLastName != null)
            ProfileInfoItem.identity(
              label: 'Full Name (Khmer)',
              value: '${staff.khmerFirstName} ${staff.khmerLastName}',
            ),
          if (staff.gender != null)
            ProfileInfoItem.identity(
              label: 'Gender',
              value: staff.gender!,
            ),
          if (staff.dateOfBirth != null)
            ProfileInfoItem.identity(
              label: 'Date of Birth',
              value: staff.dateOfBirth!,
            ),
          if (staff.nationality != null)
            ProfileInfoItem.identity(
              label: 'Nationality',
              value: staff.nationality!,
            ),
          if (staff.ethnicity != null)
            ProfileInfoItem.identity(
              label: 'Ethnicity',
              value: staff.ethnicity!,
            ),
          if (staff.staffId != null)
            ProfileInfoItem.identity(
              label: 'Staff ID',
              value: staff.staffId!,
            ),
          if (staff.identifyNumber != null)
            ProfileInfoItem.identity(
              label: 'National ID',
              value: staff.identifyNumber!,
            ),
        ]);
      }
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileInfoCardWidget(
      title: 'Personal Information',
      items: items,
    );
  }

  Widget _buildContactInformation(ProfileController controller) {
    final items = <ProfileInfoItem>[];

    items.add(ProfileInfoItem.contact(
      label: 'Email',
      value: controller.currentUserEmail,
    ));

    if (controller.currentUserPhone != null) {
      items.add(ProfileInfoItem.contact(
        label: 'Phone',
        value: controller.currentUserPhone!,
      ));
    }

    if (controller.userRole.value == 'STUDENT') {
      final student = controller.studentProfile.value;
      if (student?.currentAddress != null) {
        items.add(ProfileInfoItem.contact(
          label: 'Current Address',
          value: student!.currentAddress!,
        ));
      }
    } else if (controller.userRole.value == 'STAFF') {
      final staff = controller.staffProfile.value;
      if (staff?.currentAddress != null) {
        items.add(ProfileInfoItem.contact(
          label: 'Current Address',
          value: staff!.currentAddress!,
        ));
      }
      if (staff?.province != null) {
        items.add(ProfileInfoItem.contact(
          label: 'Province',
          value: staff!.province!,
        ));
      }
      if (staff?.district != null) {
        items.add(ProfileInfoItem.contact(
          label: 'District',
          value: staff!.district!,
        ));
      }
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileInfoCardWidget(
      title: 'Contact Information',
      items: items,
    );
  }

  Widget _buildStudentAcademicInfo(ProfileController controller) {
    final student = controller.studentProfile.value;
    if (student?.studentClass == null) {
      return const SizedBox.shrink();
    }

    final studentClass = student!.studentClass!;
    final items = <ProfileInfoItem>[];

    if (studentClass.code != null) {
      items.add(ProfileInfoItem.academic(
        label: 'Class',
        value: studentClass.code!,
      ));
    }

    if (studentClass.academyYear != null) {
      items.add(ProfileInfoItem.academic(
        label: 'Academy Year',
        value: studentClass.academyYear.toString(),
      ));
    }

    if (studentClass.yearLevel != null) {
      items.add(ProfileInfoItem.academic(
        label: 'Year Level',
        value: studentClass.yearLevel!,
      ));
    }

    if (studentClass.degree != null) {
      items.add(ProfileInfoItem.academic(
        label: 'Degree',
        value: studentClass.degree!,
      ));
    }

    if (studentClass.major?.name != null) {
      items.add(ProfileInfoItem.academic(
        label: 'Major',
        value: studentClass.major!.name!,
      ));
    }

    if (studentClass.major?.department?.name != null) {
      items.add(ProfileInfoItem.academic(
        label: 'Department',
        value: studentClass.major!.department!.name!,
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileInfoCardWidget(
      title: 'Academic Information',
      items: items,
    );
  }

  Widget _buildStaffWorkInfo(ProfileController controller) {
    final staff = controller.staffProfile.value;
    if (staff == null) {
      return const SizedBox.shrink();
    }

    final items = <ProfileInfoItem>[];

    if (staff.currentPosition != null) {
      items.add(ProfileInfoItem.work(
        label: 'Position',
        value: staff.currentPosition!,
      ));
    }

    if (staff.department?.name != null) {
      items.add(ProfileInfoItem.work(
        label: 'Department',
        value: staff.department!.name!,
      ));
    }

    if (staff.startWorkDate != null) {
      items.add(ProfileInfoItem.work(
        label: 'Start Date',
        value: staff.startWorkDate!,
      ));
    }

    if (staff.rankAndClass != null) {
      items.add(ProfileInfoItem.work(
        label: 'Rank & Class',
        value: staff.rankAndClass!,
      ));
    }

    if (staff.employeeWork != null) {
      items.add(ProfileInfoItem.work(
        label: 'Employee Work',
        value: staff.employeeWork!,
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileInfoCardWidget(
      title: 'Work Information',
      items: items,
    );
  }

  Widget _buildStudentAdditionalInfo(ProfileController controller) {
    final student = controller.studentProfile.value;
    if (student == null) return const SizedBox.shrink();

    final items = <ProfileInfoItem>[];

    if (student.memberSiblings != null) {
      items.add(ProfileInfoItem(
        label: 'Member Siblings',
        value: student.memberSiblings!,
        icon: Icons.family_restroom,
        color: AppColors.info,
      ));
    }

    if (student.numberOfSiblings != null) {
      items.add(ProfileInfoItem(
        label: 'Number of Siblings',
        value: student.numberOfSiblings!,
        icon: Icons.people,
        color: AppColors.info,
      ));
    }

    // Parent Information
    if (student.studentParent != null && student.studentParent!.isNotEmpty) {
      final parent = student.studentParent!.first;
      if (parent.englishFirstName != null && parent.englishLastName != null) {
        items.add(ProfileInfoItem(
          label: 'Parent Name',
          value: '${parent.englishFirstName} ${parent.englishLastName}',
          subtitle: parent.relationship,
          icon: Icons.supervisor_account,
          color: AppColors.success,
        ));
      }
      if (parent.occupation != null) {
        items.add(ProfileInfoItem(
          label: 'Parent Occupation',
          value: parent.occupation!,
          icon: Icons.work,
          color: AppColors.success,
        ));
      }
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileInfoCardWidget(
      title: 'Family Information',
      items: items,
      isCollapsible: true,
      initiallyExpanded: false,
    );
  }

  Widget _buildStaffAdditionalInfo(ProfileController controller) {
    final staff = controller.staffProfile.value;
    if (staff == null) return const SizedBox.shrink();

    final items = <ProfileInfoItem>[];

    if (staff.maritalStatus != null) {
      items.add(ProfileInfoItem(
        label: 'Marital Status',
        value: staff.maritalStatus!,
        icon: Icons.favorite,
        color: AppColors.error,
      ));
    }

    if (staff.officeName != null) {
      items.add(ProfileInfoItem(
        label: 'Office Name',
        value: staff.officeName!,
        icon: Icons.business,
        color: AppColors.info,
      ));
    }

    if (staff.currentPositionDate != null) {
      items.add(ProfileInfoItem(
        label: 'Current Position Date',
        value: staff.currentPositionDate!,
        icon: Icons.calendar_today,
        color: AppColors.warning,
      ));
    }

    if (staff.disability != null) {
      items.add(ProfileInfoItem(
        label: 'Disability',
        value: staff.disability!,
        icon: Icons.accessible,
        color: AppColors.info,
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileInfoCardWidget(
      title: 'Additional Information',
      items: items,
      isCollapsible: true,
      initiallyExpanded: false,
    );
  }
}
