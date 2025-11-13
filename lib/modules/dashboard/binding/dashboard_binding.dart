import 'package:get/get.dart';

import '../../../services/api_service.dart';
import '../controller/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(),);
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<ApiService>()),
    );
  }
}


