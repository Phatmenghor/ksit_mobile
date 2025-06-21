import 'package:get/get.dart';
import 'package:ksit_mobile/features/home/controllers/home_controller.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeService>(() => HomeService());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
