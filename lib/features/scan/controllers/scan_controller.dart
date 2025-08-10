// lib/features/scan/controllers/scan_controller.dart (Simplified Working Version)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ksit_mobile/features/scan/models/qr_attendance_response_models.dart';

import '../../../core/utils/logger_utils.dart';
import '../../../core/utils/api_error_utils.dart';
import '../services/qr_attendance_service.dart';
import '../widgets/attendance_result_modal.dart';

class ScanController extends GetxController {
  final QrAttendanceService _qrAttendanceService =
      Get.put(QrAttendanceService());

  // Mobile Scanner Controller
  late MobileScannerController scannerController;

  // Observables
  final RxBool isFlashOn = false.obs;
  final RxBool isSubmittingAttendance = false.obs;
  final RxString scannedQrCode = ''.obs;
  final RxBool isScannerReady = false.obs;
  final RxBool canScan = true.obs;
  final Rx<CameraFacing> cameraFacing = CameraFacing.back.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeScanner();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void _initializeScanner() {
    try {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      isScannerReady.value = true;
      LoggerUtils.info('Scanner initialized successfully');
    } catch (e) {
      LoggerUtils.error('Failed to initialize scanner', e);
    }
  }

  void onDetect(BarcodeCapture capture) {
    if (!canScan.value || isSubmittingAttendance.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _processScanResult(code);
        break;
      }
    }
  }

  void toggleFlash() {
    try {
      scannerController.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
      LoggerUtils.info('Flash toggled: ${isFlashOn.value}');
    } catch (e) {
      LoggerUtils.error('Failed to toggle flash', e);
    }
  }

  void switchCamera() {
    try {
      scannerController.switchCamera();
      cameraFacing.value = cameraFacing.value == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;
      LoggerUtils.info('Camera switched to: ${cameraFacing.value}');
    } catch (e) {
      LoggerUtils.error('Failed to switch camera', e);
    }
  }

  void _processScanResult(String result) {
    if (isSubmittingAttendance.value || !canScan.value) return;

    scannedQrCode.value = result;
    canScan.value = false; // Prevent multiple scans
    LoggerUtils.info('QR Code scanned: $result');

    // Submit attendance immediately
    _submitAttendance(result);
  }

  Future<void> _submitAttendance(String qrCode) async {
    try {
      isSubmittingAttendance.value = true;

      final response = await _qrAttendanceService.markAttendanceByQr(qrCode);

      if (response.isSuccess) {
        _showSuccessModal(response);
      } else {
        _showErrorModal(response.message);
      }
    } catch (e) {
      final errorMessage = ApiErrorUtils.extractApiErrorMessage(e);
      _showErrorModal(errorMessage);
      LoggerUtils.error('Error submitting attendance', e);
    } finally {
      isSubmittingAttendance.value = false;
    }
  }

  void _showSuccessModal(QrAttendanceResponse response) {
    AttendanceResultModal.showSuccess(
      title: 'Check-in!',
      message: response.message,
      attendanceData: response.data,
      onDone: () {
        Get.back();
        // Re-enable scanning after a delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          canScan.value = true;
        });
      },
    );
  }

  void _showErrorModal(String errorMessage) {
    AttendanceResultModal.showError(
      title: 'Scan Failed!',
      message: errorMessage,
      onRetry: () {
        Get.back();
        // Re-enable scanning immediately for retry
        Future.delayed(const Duration(milliseconds: 500), () {
          canScan.value = true;
        });
      },
    );
  }

  void resetScanning() {
    canScan.value = true;
    isSubmittingAttendance.value = false;
    scannedQrCode.value = '';
  }

  void pauseScanning() {
    canScan.value = false;
  }

  void resumeScanning() {
    canScan.value = true;
  }

  // Simplified camera lifecycle methods
  void startScanner() {
    try {
      LoggerUtils.info('Scanner start requested');
      resetScanning();
    } catch (e) {
      LoggerUtils.error('Failed to start scanner', e);
    }
  }

  void stopScanner() {
    try {
      pauseScanning();
      LoggerUtils.info('Scanner stopped');
    } catch (e) {
      LoggerUtils.error('Failed to stop scanner', e);
    }
  }
}
