// lib/features/scan/controllers/scan_controller.dart (With Detection Delay)
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

  // Detection and scanning states
  final RxBool isDetecting = false.obs; // When QR is detected but waiting
  final RxBool isScanning = false.obs; // When actually processing
  final RxInt scanCooldownSeconds = 0.obs;
  final RxInt detectionCountdown = 0.obs; // Countdown for detection delay
  final RxBool hasScannedInSession = false.obs;

  // Zoom controls
  final RxDouble currentZoom = 1.0.obs;
  final RxDouble minZoom = 1.0.obs;
  final RxDouble maxZoom = 3.0.obs;

  // Timing settings
  static const int detectionDelayDuration =
      2; // 2 seconds to confirm QR detection
  static const int scanCooldownDuration = 3; // 3 seconds cooldown between scans

  Timer? _cooldownTimer;
  Timer? _detectionTimer;
  Timer? _detectionCountdownTimer;
  String? _pendingQrCode;

  @override
  void onInit() {
    super.onInit();
    _initializeScanner();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    _detectionTimer?.cancel();
    _detectionCountdownTimer?.cancel();
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
        detectionSpeed: DetectionSpeed
            .normal, // Changed from noDuplicates for better control
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      LoggerUtils.info('Scanner initialized successfully');
    } catch (e) {
      LoggerUtils.error('Failed to initialize scanner', e);
    }
  }

  void onDetect(BarcodeCapture capture) {
    // Check if we can scan
    if (!canScan.value ||
        isScanning.value ||
        isSubmittingAttendance.value ||
        isDetecting.value) {
      return;
    }

    // Check cooldown
    if (scanCooldownSeconds.value > 0) {
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _startDetectionDelay(code);
        break;
      }
    }
  }

  void _startDetectionDelay(String qrCode) {
    // Prevent multiple detections
    if (isDetecting.value) return;

    isDetecting.value = true;
    _pendingQrCode = qrCode;
    detectionCountdown.value = detectionDelayDuration;

    // Light haptic feedback on detection
    HapticFeedback.selectionClick();

    LoggerUtils.info('QR Code detected, starting detection delay: $qrCode');

    // Start countdown timer
    _detectionCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (detectionCountdown.value <= 1) {
        detectionCountdown.value = 0;
        timer.cancel();
        _processScanResult();
      } else {
        detectionCountdown.value--;
      }
    });

    // Auto-cancel if user moves QR away
    _detectionTimer = Timer(Duration(seconds: detectionDelayDuration), () {
      if (isDetecting.value && _pendingQrCode == qrCode) {
        _processScanResult();
      }
    });
  }

  void _cancelDetection() {
    _detectionTimer?.cancel();
    _detectionCountdownTimer?.cancel();
    isDetecting.value = false;
    detectionCountdown.value = 0;
    _pendingQrCode = null;
    LoggerUtils.info('Detection cancelled');
  }

  void _processScanResult() {
    if (_pendingQrCode == null ||
        isScanning.value ||
        isSubmittingAttendance.value) return;

    // Clear detection state
    _detectionTimer?.cancel();
    _detectionCountdownTimer?.cancel();
    isDetecting.value = false;
    detectionCountdown.value = 0;

    // Set scanning state
    isScanning.value = true;
    canScan.value = false;
    scannedQrCode.value = _pendingQrCode!;

    // Medium haptic feedback for actual scan
    HapticFeedback.mediumImpact();

    LoggerUtils.info('Processing QR Code: ${_pendingQrCode}');

    // Start submission
    _submitAttendance(_pendingQrCode!);
    _pendingQrCode = null;
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
      _startScanCooldown();
    }
  }

  void _showSuccessModal(QrAttendanceResponse response) {
    // Success haptic feedback
    HapticFeedback.lightImpact();

    AttendanceResultModal.showSuccess(
      title: 'Attendance Recorded Successfully',
      message: response.message,
      attendanceData: response.data,
      onDone: () {
        Get.back();
        LoggerUtils.info('Success modal dismissed');
      },
    );
  }

  void _showErrorModal(String errorMessage) {
    // Error haptic feedback
    HapticFeedback.vibrate();

    AttendanceResultModal.showError(
      title: 'Attendance Failed',
      message: errorMessage,
      onRetry: () {
        Get.back();
        _startScanCooldown(duration: 1); // Quick retry
      },
    );
  }

  void _startScanCooldown({int duration = scanCooldownDuration}) {
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
      }
    });

    LoggerUtils.info('Scan cooldown started: ${duration}s');
  }

  // Manual cancel detection (if user wants to cancel)
  void cancelCurrentDetection() {
    if (isDetecting.value) {
      _cancelDetection();
      HapticFeedback.selectionClick();
    }
  }

  // Zoom controls
  void zoomIn() {
    final newZoom =
        (currentZoom.value + 0.2).clamp(minZoom.value, maxZoom.value);
    currentZoom.value = newZoom;
    HapticFeedback.selectionClick();
  }

  void zoomOut() {
    final newZoom =
        (currentZoom.value - 0.2).clamp(minZoom.value, maxZoom.value);
    currentZoom.value = newZoom;
    HapticFeedback.selectionClick();
  }

  void resetZoom() {
    currentZoom.value = 1.0;
    HapticFeedback.selectionClick();
  }

  // Flash and camera controls
  Future<void> toggleFlash() async {
    try {
      await scannerController.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
      HapticFeedback.selectionClick();
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
    } catch (e) {
      LoggerUtils.error('Failed to switch camera', e);
    }
  }

  // Reset scanning session
  void resetSession() {
    _cooldownTimer?.cancel();
    _detectionTimer?.cancel();
    _detectionCountdownTimer?.cancel();

    isDetecting.value = false;
    isScanning.value = false;
    isSubmittingAttendance.value = false;
    canScan.value = true;
    scanCooldownSeconds.value = 0;
    detectionCountdown.value = 0;
    hasScannedInSession.value = false;
    scannedQrCode.value = '';
    currentZoom.value = 1.0;
    _pendingQrCode = null;

    LoggerUtils.info('Scan session reset');
  }

  // Status getters
  bool get canStartNewScan =>
      canScan.value &&
      !isScanning.value &&
      !isDetecting.value &&
      scanCooldownSeconds.value == 0;

  String get scanStatus {
    if (isSubmittingAttendance.value) return 'Processing...';
    if (isScanning.value) return 'Scanning...';
    if (isDetecting.value)
      return 'Detected! Scanning in ${detectionCountdown.value}s';
    if (scanCooldownSeconds.value > 0)
      return 'Wait ${scanCooldownSeconds.value}s';
    if (!canScan.value) return 'Ready';
    return 'Position QR Code';
  }

  String get zoomDisplay => '${currentZoom.value.toStringAsFixed(1)}x';
}
