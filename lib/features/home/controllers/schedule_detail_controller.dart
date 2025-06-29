import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/core/utils/logger_utils.dart';
import 'package:ksit_mobile/core/utils/toast_utils.dart';
import 'package:ksit_mobile/features/home/models/schedule_models.dart';
import 'package:ksit_mobile/features/home/services/home_service.dart';

class ScheduleDetailController extends GetxController {
  final int scheduleId;
  final HomeService _homeService = Get.find<HomeService>();

  ScheduleDetailController({required this.scheduleId});

  // Observables
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ScheduleModel?> schedule = Rx<ScheduleModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadScheduleDetails();
  }

  Future<void> loadScheduleDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      LoggerUtils.info('Loading schedule details for ID: $scheduleId');

      final scheduleData = await _homeService.getScheduleById(scheduleId);

      if (scheduleData != null) {
        schedule.value = scheduleData;
        LoggerUtils.info('Schedule details loaded successfully');
      } else {
        errorMessage.value = 'Schedule not found';
        LoggerUtils.warning('Schedule not found for ID: $scheduleId');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load schedule details. Please try again.';
      LoggerUtils.error('Error loading schedule details', e);
      ToastUtils.showError('Failed to load schedule details');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshSchedule() {
    loadScheduleDetails();
  }
}

// 5. Update home_controller.dart - Replace the onScheduleTap method
void onScheduleTap(ScheduleModel schedule) {
  LoggerUtils.info('Schedule tapped: ${schedule.id}');

  if (schedule.id != null) {
    // Navigate to schedule detail with ID as query parameter
    Get.context?.go('${AppRoutes.scheduleDetailRoute}?id=${schedule.id}');
  } else {
    ToastUtils.showError('Schedule ID not available');
  }
}
