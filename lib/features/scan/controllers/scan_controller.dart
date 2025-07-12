// Updated lib/features/scan/controllers/scan_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/features/scan/models/qr_attendance_response_models.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../core/utils/logger_utils.dart';
import '../../../core/utils/api_error_utils.dart';
import '../services/qr_attendance_service.dart';
import '../widgets/attendance_result_modal.dart';

class ScanController extends GetxController {
  final QrAttendanceService _qrAttendanceService =
      Get.put(QrAttendanceService());

  // QR Scanner
  QRViewController? qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // Observables
  final RxBool isFlashOn = false.obs;
  final RxBool isSubmittingAttendance = false.obs;
  final RxString scannedQrCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    qrController?.dispose();
    super.onClose();
  }

  void onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isSubmittingAttendance.value && scanData.code != null) {
        _processScanResult(scanData.code!);
      }
    });
  }

  void toggleFlash() {
    qrController?.toggleFlash();
    isFlashOn.value = !isFlashOn.value;
    LoggerUtils.info('Flash toggled: ${isFlashOn.value}');
  }

  void flipCamera() {
    qrController?.flipCamera();
    LoggerUtils.info('Camera flipped');
  }

  void _processScanResult(String result) {
    if (isSubmittingAttendance.value) return;

    scannedQrCode.value = result;
    LoggerUtils.info('QR Code scanned: $result');

    // Pause camera while processing
    qrController?.pauseCamera();

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
        // Resume camera for next scan
        Future.delayed(const Duration(milliseconds: 500), () {
          qrController?.resumeCamera();
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
        // Resume camera for retry
        Future.delayed(const Duration(milliseconds: 500), () {
          qrController?.resumeCamera();
        });
      },
    );
  }

  void resumeCamera() {
    qrController?.resumeCamera();
  }

  void pauseCamera() {
    qrController?.pauseCamera();
  }
}
