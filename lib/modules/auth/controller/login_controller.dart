import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gopal_interview_webworks/main.dart';

import '../../../routes/app_routes.dart';
import '../../../services/notification_service.dart';
import '../../../utils/constants/app_strings.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordObscured = true.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 800));

    await NotificationService().showLoginSuccessNotification(
      title: AppStrings.loginNotificationTitle,
      body: AppStrings.loginNotificationBody,
    );

    isLoading.value = false;
    getStorage.write("isLoggedIn", true);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
