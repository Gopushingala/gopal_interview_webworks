import 'package:get/get.dart';
import 'package:gopal_interview_webworks/modules/dashboard/dashboard_view.dart';

import '../modules/auth/login_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/dashboard/dashboard_binding.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
}


class AppPages {

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}

