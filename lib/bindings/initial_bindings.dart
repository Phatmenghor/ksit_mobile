import 'package:get/get.dart';
import 'package:ksit_mobile/core/services/api_service.dart';
import 'package:ksit_mobile/core/services/firebase_service.dart';
import 'package:ksit_mobile/core/services/storage_service.dart';

import '../../features/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize storage service first
    final storageService = await StorageService.getInstance();
    Get.put<StorageService>(storageService, permanent: true);

    // Initialize other services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<FirebaseService>(FirebaseService(), permanent: true);

    // Initialize controllers
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
