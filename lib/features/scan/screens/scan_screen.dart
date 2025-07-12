// Updated lib/features/scan/screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/scan_controller.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final scanController = Get.put(ScanController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      scanController.resumeCamera();
    } else if (state == AppLifecycleState.paused) {
      scanController.pauseCamera();
    }
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
          IconButton(
            onPressed: scanController.flipCamera,
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full Screen QR Camera
          _buildQRView(),

          // Bottom Instructions
          Positioned(
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
                      child: const Text(
                        'Position QR code within the frame',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Processing Overlay
          Obx(() => scanController.isSubmittingAttendance.value
              ? Container(
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildQRView() {
    return QRView(
      key: scanController.qrKey,
      onQRViewCreated: scanController.onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: AppColors.primary,
        borderRadius: 12,
        borderLength: 40,
        borderWidth: 8,
        cutOutSize: 280,
        cutOutBottomOffset: 80,
      ),
      onPermissionSet: (ctrl, hasPermission) {
        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required for QR scanning'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
