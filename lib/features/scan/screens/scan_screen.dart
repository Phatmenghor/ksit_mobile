// lib/features/scan/screens/scan_screen.dart (Simple Working Version)
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Simple animation for scanning line
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

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          // Simple Mobile Scanner - handles permissions automatically
          MobileScanner(
            controller: scanController.scannerController,
            onDetect: scanController.onDetect,
            overlay: _buildScanOverlay(),
          ),

          // Processing Overlay
          Obx(() => scanController.isSubmittingAttendance.value
              ? _buildProcessingOverlay()
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
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary,
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
                      color: AppColors.primary,
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

              // Animated scanning line
              Obx(() => scanController.canScan.value &&
                      !scanController.isSubmittingAttendance.value
                  ? AnimatedBuilder(
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
                    )
                  : const SizedBox.shrink()),

              // Center focus point
              Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
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
                child: Obx(() => Text(
                      scanController.canScan.value
                          ? 'Position QR code within the frame'
                          : 'Processing QR code...',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
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
              'Processing attendance...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait',
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
}
