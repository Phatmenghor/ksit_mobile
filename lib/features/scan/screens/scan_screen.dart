import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/scan_controller.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scanController = Get.put(ScanController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: scanController.toggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: scanController.flipCamera,
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // Camera/Scanner Area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  child: scanController.isCameraActive.value
                      ? _buildCameraView(scanController)
                      : _buildInactiveCameraView(scanController),
                ),
              ),
            ),

            // Controls Section
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Scan Result
                    if (scanController.lastScanResult.value.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppConstants.defaultPadding),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Scan Result:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scanController.lastScanResult.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Control Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: scanController.isCameraActive.value
                                ? 'Stop Camera'
                                : 'Start Camera',
                            onPressed: scanController.toggleCamera,
                            type: scanController.isCameraActive.value
                                ? ButtonType.secondary
                                : ButtonType.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Manual Input',
                            onPressed: scanController.showManualInputDialog,
                            type: ButtonType.secondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Scan History Button
                    CustomButton(
                      text: 'View Scan History',
                      onPressed: scanController.viewScanHistory,
                      type: ButtonType.text,
                      width: double.infinity,
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

  Widget _buildCameraView(ScanController controller) {
    return Stack(
      children: [
        // Camera preview would go here
        Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'Camera Preview\n(QR/Barcode Scanner)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Scan overlay
        _buildScanOverlay(),

        // Status indicator
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: controller.isScanning.value
                  ? AppColors.success
                  : AppColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              controller.isScanning.value ? 'Scanning...' : 'Ready',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveCameraView(ScanController controller) {
    return Container(
      color: AppColors.border.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera Inactive',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap "Start Camera" to begin scanning',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            ...List.generate(4, (index) {
              return Positioned(
                top: index < 2 ? 0 : null,
                bottom: index >= 2 ? 0 : null,
                left: index % 2 == 0 ? 0 : null,
                right: index % 2 == 1 ? 0 : null,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          index == 0 ? const Radius.circular(10) : Radius.zero,
                      topRight:
                          index == 1 ? const Radius.circular(10) : Radius.zero,
                      bottomLeft:
                          index == 2 ? const Radius.circular(10) : Radius.zero,
                      bottomRight:
                          index == 3 ? const Radius.circular(10) : Radius.zero,
                    ),
                  ),
                ),
              );
            }),

            // Center text
            const Center(
              child: Text(
                'Position QR code\nwithin the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
