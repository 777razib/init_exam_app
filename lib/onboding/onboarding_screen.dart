import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  final void Function(String username) onProceed;

  const OnboardingScreen({Key? key, required this.onProceed}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final RxBool _isDarkMode = false.obs;
  final RxBool _isButtonEnabled = false.obs;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _usernameController.addListener(() {
      _isButtonEnabled(_usernameController.text.trim().isNotEmpty);
    });
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleTheme(bool value) async {
    _isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void _onProceed() {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      widget.onProceed(username);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Fixed: EdgeInsets.all
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Enter GitHub Username',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'e.g., torvalds, flutter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: '777razib',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onSubmitted: (_) => _onProceed(),
            ),
            const SizedBox(height: 24),
            Obx(() => SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: Icon(_isDarkMode.value ? Icons.dark_mode : Icons.light_mode),
              value: _isDarkMode.value,
              onChanged: _toggleTheme,
              activeColor: Colors.teal,
            )),
            const SizedBox(height: 32),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isButtonEnabled.value ? _onProceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled.value ? null : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Proceed to Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}