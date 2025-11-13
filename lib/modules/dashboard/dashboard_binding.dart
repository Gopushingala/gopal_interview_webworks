import 'package:get/get.dart';

import '../../core/services/api_service.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(),);
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<ApiService>()),
    );
  }
}


