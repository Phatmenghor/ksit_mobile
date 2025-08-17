// lib/features/scan/screens/scan_screen.dart (With Detection Delay UI)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/scan_controller.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  final scanController = Get.put(ScanController());
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for scanning line
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for detection state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'QR Scan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // Flash Toggle
          Obx(() => IconButton(
                onPressed: scanController.toggleFlash,
                icon: Icon(
                  scanController.isFlashOn.value
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                  size: 24,
                ),
              )),

          // Camera Switch
          Obx(() => IconButton(
                onPressed: scanController.switchCamera,
                icon: Icon(
                  scanController.cameraFacing.value == CameraFacing.back
                      ? Icons.camera_rear
                      : Icons.camera_front,
                  color: Colors.white,
                  size: 24,
                ),
              )),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: scanController.scannerController,
            onDetect: scanController.onDetect,
            overlay: _buildScanOverlay(),
          ),

          // Processing Overlay
          Obx(() => scanController.isSubmittingAttendance.value
              ? _buildProcessingOverlay()
              : const SizedBox.shrink()),

          // Detection Countdown Overlay
          Obx(() => scanController.isDetecting.value
              ? _buildDetectionOverlay()
              : const SizedBox.shrink()),

          // Cooldown Overlay
          Obx(() => scanController.scanCooldownSeconds.value > 0
              ? _buildCooldownOverlay()
              : const SizedBox.shrink()),

          // Bottom Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: Obx(() {
          // Change border color based on state
          Color borderColor = AppColors.primary;
          if (scanController.isDetecting.value) {
            borderColor = AppColors.warning;
          } else if (scanController.isScanning.value) {
            borderColor = AppColors.success;
          }

          return AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              double scale = scanController.isDetecting.value
                  ? _pulseAnimation.value
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Corner brackets
                      ...List.generate(4, (index) {
                        return Positioned(
                          top: index < 2 ? -3 : null,
                          bottom: index >= 2 ? -3 : null,
                          left: index % 2 == 0 ? -3 : null,
                          right: index % 2 == 1 ? -3 : null,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.only(
                                topLeft: index == 0
                                    ? const Radius.circular(17)
                                    : Radius.zero,
                                topRight: index == 1
                                    ? const Radius.circular(17)
                                    : Radius.zero,
                                bottomLeft: index == 2
                                    ? const Radius.circular(17)
                                    : Radius.zero,
                                bottomRight: index == 3
                                    ? const Radius.circular(17)
                                    : Radius.zero,
                              ),
                            ),
                          ),
                        );
                      }),

                      // Animated scanning line (only when ready to scan)
                      if (scanController.canScan.value &&
                          !scanController.isSubmittingAttendance.value &&
                          !scanController.isDetecting.value &&
                          scanController.scanCooldownSeconds.value == 0)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: _animation.value * 260,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Center focus point
                      Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: borderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildDetectionOverlay() {
    // Start pulse animation when detecting
    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Detection countdown circle
            Obx(() => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warning,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${scanController.detectionCountdown.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'sec',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            const Text(
              'QR Code Detected!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Scanning in progress...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // Cancel button
            TextButton(
              onPressed: scanController.cancelCurrentDetection,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCooldownOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cooldown Timer
            Obx(() => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.info,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${scanController.scanCooldownSeconds.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'sec',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            const Text(
              'Ready to scan again in...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please wait to prevent duplicate scans',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Processing Attendance...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait while we record your attendance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Obx(() {
                  String message;
                  Color textColor = Colors.black87;

                  if (scanController.isSubmittingAttendance.value) {
                    message = 'Processing attendance...';
                  } else if (scanController.isDetecting.value) {
                    message =
                        'QR detected! Scanning in ${scanController.detectionCountdown.value}s';
                    textColor = Colors.orange.shade800;
                  } else if (scanController.scanCooldownSeconds.value > 0) {
                    message =
                        'Wait ${scanController.scanCooldownSeconds.value}s before next scan';
                    textColor = Colors.blue.shade800;
                  } else if (scanController.canScan.value) {
                    message =
                        'Hold steady - QR code will be detected automatically';
                  } else {
                    message = 'Camera not ready';
                    textColor = Colors.red.shade800;
                  }

                  return Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
