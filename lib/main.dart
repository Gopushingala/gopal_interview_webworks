import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'routes/app_routes.dart';

final getStorage = GetStorage();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCrpNqZZRjUJq2pcwrHfanSMsFrCd03cEk",
        appId: "1:752901099619:android:09fa00af502dc054c6a856",
        projectId: "gopal-interview-webworks",
        messagingSenderId: ''),
  );
  await NotificationService().initialize();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = getStorage.read("isLoggedIn")??false;
    return GetMaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute:isLoggedIn==false? AppRoutes.login:AppRoutes.dashboard,
      getPages: AppPages.pages,
    );
  }
}
