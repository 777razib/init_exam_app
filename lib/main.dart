// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cores/theme_controller.dart';
import 'home/screen/home_screen.dart';
import 'login/controller/login_controller.dart';
import 'onboding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize ThemeController
    Get.put(ThemeController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub User Profile App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: OnboardingScreen(
        onProceed: (username) async {
          // Fetch user data before navigating
          final loginCtrl = Get.put(LoginController());
          final user = await loginCtrl.login(username);
          if (user != null) {
            Get.offAll(() => HomeScreen(user: user));
          } else {
            // Show error if user not found
            Get.snackbar(
              'Error',
              loginCtrl.error.value.isNotEmpty 
                ? loginCtrl.error.value 
                : 'Failed to load user',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }
}







