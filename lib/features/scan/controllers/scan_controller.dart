// lib/features/scan/controllers/scan_controller.dart (Fixed with immediate cooldown)
import 'dart:async';
import 'package:flutter/services.dart';
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
  final RxBool canScan = true.obs;
  final Rx<CameraFacing> cameraFacing = CameraFacing.back.obs;

  // Banking-style scanning controls
  final RxBool isScanning = false.obs;
  final RxInt scanCooldownSeconds = 0.obs;
  final RxBool hasScannedInSession = false.obs;

  // Zoom controls (UI-based since API doesn't support it)
  final RxDouble currentZoom = 1.0.obs;
  final RxDouble minZoom = 1.0.obs;
  final RxDouble maxZoom = 3.0.obs;

  // Scan delay settings (like banking apps)
  static const int scanDelayDuration = 5; // 5 seconds delay between scans
  static const int processingDelay = 1; // 1 second processing simulation

  Timer? _cooldownTimer;
  Timer? _processingTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeScanner();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    _processingTimer?.cancel();
    try {
      scannerController.dispose();
    } catch (e) {
      LoggerUtils.error('Error disposing scanner controller', e);
    }
    super.onClose();
  }

  void _initializeScanner() {
    try {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      LoggerUtils.info('Scanner initialized successfully');
    } catch (e) {
      LoggerUtils.error('Failed to initialize scanner', e);
    }
  }

  void onDetect(BarcodeCapture capture) {
    // Banking-style scan controls
    if (!canScan.value || isScanning.value || isSubmittingAttendance.value) {
      return;
    }

    // Prevent multiple scans too quickly
    if (scanCooldownSeconds.value > 0) {
      LoggerUtils.info(
          'Scan blocked - cooldown active: ${scanCooldownSeconds.value}s');
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _processScanResult(code);
        break;
      }
    }
  }

  void _processScanResult(String result) {
    if (isScanning.value || isSubmittingAttendance.value) return;

    // Set scanning state
    isScanning.value = true;
    canScan.value = false;
    scannedQrCode.value = result;

    // Start cooldown immediately after scan detection
    _startScanCooldown();

    // Haptic feedback (like banking apps)
    HapticFeedback.mediumImpact();

    LoggerUtils.info('QR Code scanned: $result');

    // Banking-style processing delay
    _processingTimer = Timer(Duration(seconds: processingDelay), () {
      _submitAttendance(result);
    });
  }

  Future<void> _submitAttendance(String qrCode) async {
    try {
      isSubmittingAttendance.value = true;

      final response = await _qrAttendanceService.markAttendanceByQr(qrCode);

      if (response.isSuccess) {
        hasScannedInSession.value = true;
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
      isScanning.value = false;
    }
  }

  void _showSuccessModal(QrAttendanceResponse response) {
    // Success haptic feedback
    HapticFeedback.lightImpact();

    AttendanceResultModal.showSuccess(
      title: 'Attendance Recorded',
      message: response.message,
      attendanceData: response.data,
      onDone: () {
        Get.back();
        // Cooldown already started, just log
        LoggerUtils.info('Success modal dismissed - cooldown already active');
      },
    );
  }

  void _showErrorModal(String errorMessage) {
    // Error haptic feedback
    HapticFeedback.vibrate();

    AttendanceResultModal.showError(
      title: 'Scan Failed',
      message: errorMessage,
      onRetry: () {
        Get.back();
        // Reset cooldown for retry (shorter duration)
        _resetForRetry();
      },
    );
  }

  void _startScanCooldown({int duration = scanDelayDuration}) {
    scanCooldownSeconds.value = duration;

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (scanCooldownSeconds.value <= 1) {
        scanCooldownSeconds.value = 0;
        canScan.value = true;
        timer.cancel();
        LoggerUtils.info('Scan cooldown ended - ready to scan');
      } else {
        scanCooldownSeconds.value--;
        LoggerUtils.debug('Cooldown: ${scanCooldownSeconds.value}s remaining');
      }
    });

    LoggerUtils.info('Scan cooldown started: ${duration}s');
  }

  void _resetForRetry() {
    // For retry, use shorter cooldown
    _cooldownTimer?.cancel();
    _startScanCooldown(duration: 2);
    LoggerUtils.info('Retry cooldown started: 2s');
  }

  // Zoom controls (UI simulation since API doesn't support real zoom)
  void zoomIn() {
    final newZoom =
        (currentZoom.value + 0.2).clamp(minZoom.value, maxZoom.value);
    currentZoom.value = newZoom;
    HapticFeedback.selectionClick();
    LoggerUtils.info('Zoom in: ${currentZoom.value.toStringAsFixed(1)}x');
  }

  void zoomOut() {
    final newZoom =
        (currentZoom.value - 0.2).clamp(minZoom.value, maxZoom.value);
    currentZoom.value = newZoom;
    HapticFeedback.selectionClick();
    LoggerUtils.info('Zoom out: ${currentZoom.value.toStringAsFixed(1)}x');
  }

  void resetZoom() {
    currentZoom.value = 1.0;
    HapticFeedback.selectionClick();
    LoggerUtils.info('Zoom reset to 1.0x');
  }

  // Flash and camera controls
  Future<void> toggleFlash() async {
    try {
      await scannerController.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
      HapticFeedback.selectionClick();
      LoggerUtils.info('Flash toggled: ${isFlashOn.value}');
    } catch (e) {
      LoggerUtils.error('Failed to toggle flash', e);
    }
  }

  Future<void> switchCamera() async {
    try {
      await scannerController.switchCamera();
      cameraFacing.value = cameraFacing.value == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;

      HapticFeedback.selectionClick();
      LoggerUtils.info('Camera switched to: ${cameraFacing.value}');
    } catch (e) {
      LoggerUtils.error('Failed to switch camera', e);
    }
  }

  // Manual scan trigger (for testing)
  void manualScan() {
    if (canScan.value && !isScanning.value && scanCooldownSeconds.value == 0) {
      // Simulate a QR code scan for testing
      _processScanResult(
          'TEST_QR_CODE_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  // Reset scanning session
  void resetSession() {
    _cooldownTimer?.cancel();
    _processingTimer?.cancel();

    isScanning.value = false;
    isSubmittingAttendance.value = false;
    canScan.value = true;
    scanCooldownSeconds.value = 0;
    hasScannedInSession.value = false;
    scannedQrCode.value = '';
    currentZoom.value = 1.0;

    LoggerUtils.info('Scan session reset');
  }

  void pauseScanning() {
    canScan.value = false;
    isScanning.value = false;
  }

  void resumeScanning() {
    if (!isSubmittingAttendance.value && scanCooldownSeconds.value == 0) {
      canScan.value = true;
    }
  }

  // Status getters
  bool get canStartNewScan =>
      canScan.value && !isScanning.value && scanCooldownSeconds.value == 0;

  String get scanStatus {
    if (isSubmittingAttendance.value) return 'Processing...';
    if (isScanning.value) return 'Scanning...';
    if (scanCooldownSeconds.value > 0)
      return 'Wait ${scanCooldownSeconds.value}s';
    if (!canScan.value) return 'Ready';
    return 'Scan QR Code';
  }

  String get zoomDisplay => '${currentZoom.value.toStringAsFixed(1)}x';
}
