import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cores/theme_controller.dart';
import 'home/screen/home_screen.dart';
import 'login/controller/login_controller.dart';
import 'onboding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  Get.put(LoginController()); // Initialize LoginController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub User Profile App',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: OnboardingScreen(
        onProceed: (username) async {
          final loginCtrl = Get.find<LoginController>();
          final user = await loginCtrl.login(username);
          if (user != null) {
            Get.offAll(() => HomeScreen(user: user));
          } else {
            Get.snackbar(
              'Error',
              loginCtrl.error.value.isNotEmpty ? loginCtrl.error.value : 'Failed to load user',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }
}