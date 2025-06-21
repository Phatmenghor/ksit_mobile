import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/utils/logger_utils.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class ScanController extends GetxController {
  // Observables
  final RxBool isCameraActive = false.obs;
  final RxBool isScanning = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxString lastScanResult = ''.obs;
  final RxList<String> scanHistory = <String>[].obs;

  // Text controller for manual input
  final manualInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadScanHistory();
  }

  @override
  void onClose() {
    manualInputController.dispose();
    super.onClose();
  }

  void _loadScanHistory() {
    // TODO: Load scan history from storage
    scanHistory.addAll([
      'QR12345ABC',
      'BAR98765XYZ',
      'SCAN123456',
    ]);
  }

  void toggleCamera() {
    if (isCameraActive.value) {
      _stopCamera();
    } else {
      _startCamera();
    }
  }

  void _startCamera() {
    try {
      isCameraActive.value = true;
      isScanning.value = true;
      LoggerUtils.info('Camera started');

      Fluttertoast.showToast(
        msg: 'Camera started - Ready to scan',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Simulate scan detection after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (isCameraActive.value) {
          _simulateScanResult();
        }
      });
    } catch (e) {
      LoggerUtils.error('Error starting camera', e);
      Fluttertoast.showToast(
        msg: 'Failed to start camera',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _stopCamera() {
    try {
      isCameraActive.value = false;
      isScanning.value = false;
      LoggerUtils.info('Camera stopped');

      Fluttertoast.showToast(
        msg: 'Camera stopped',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      LoggerUtils.error('Error stopping camera', e);
    }
  }

  void _simulateScanResult() {
    final simulatedResults = [
      'QR12345ABC',
      'BAR98765XYZ',
      'SCAN123456',
      'CODE789DEF',
      'TEST456GHI',
    ];

    final randomResult = simulatedResults[
        DateTime.now().millisecondsSinceEpoch % simulatedResults.length];

    _processScanResult(randomResult);
  }

  void toggleFlash() {
    if (!isCameraActive.value) {
      Fluttertoast.showToast(
        msg: 'Please start camera first',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    isFlashOn.value = !isFlashOn.value;
    LoggerUtils.info('Flash toggled: ${isFlashOn.value}');

    Fluttertoast.showToast(
      msg: isFlashOn.value ? 'Flash ON' : 'Flash OFF',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void flipCamera() {
    if (!isCameraActive.value) {
      Fluttertoast.showToast(
        msg: 'Please start camera first',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    LoggerUtils.info('Camera flipped');

    Fluttertoast.showToast(
      msg: 'Camera flipped',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _processScanResult(String result) {
    lastScanResult.value = result;
    scanHistory.insert(0, result);

    // Keep only last 50 scans
    if (scanHistory.length > 50) {
      scanHistory.removeRange(50, scanHistory.length);
    }

    LoggerUtils.info('Scan result processed: $result');

    Fluttertoast.showToast(
      msg: 'Scanned: $result',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    // TODO: Send scan result to backend
    _sendScanResultToBackend(result);
  }

  Future<void> _sendScanResultToBackend(String result) async {
    try {
      // TODO: Implement API call to send scan result
      LoggerUtils.info('Sending scan result to backend: $result');
    } catch (e) {
      LoggerUtils.error('Error sending scan result to backend', e);
    }
  }

  void showManualInputDialog() {
    manualInputController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Manual Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the code manually:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: manualInputController,
              hint: 'Enter code here',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitManualInput(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Submit',
            onPressed: _submitManualInput,
          ),
        ],
      ),
    );
  }

  void _submitManualInput() {
    final input = manualInputController.text.trim();
    if (input.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a code',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Get.back(); // Close dialog
    _processScanResult(input);
  }

  void viewScanHistory() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Scan History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // History list
            Expanded(
              child: Obx(() {
                if (scanHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      'No scan history',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: scanHistory.length,
                  itemBuilder: (context, index) {
                    final scan = scanHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.qr_code),
                        title: Text(scan),
                        subtitle: Text('Scan ${index + 1}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyScanResult(scan),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _copyScanResult(String result) {
    // TODO: Copy to clipboard
    Fluttertoast.showToast(
      msg: 'Copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
