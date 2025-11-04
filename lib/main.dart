// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home/screen/home_screen.dart';
import 'onboding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GitHub User Profile App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: OnboardingScreen(
        onProceed: (username) {
          Get.offAll(() => HomeScreen(username: username));
        },
      ),
    );
  }
}







