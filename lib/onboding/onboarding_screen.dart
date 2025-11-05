import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../cores/theme_controller.dart';

class OnboardingScreen extends StatelessWidget {
  final void Function(String username) onProceed;

  // ── 1. Make the text field observable ─────────────────────
  final _usernameRx = ''.obs;
  final _controller = TextEditingController();

  // Listen to the native controller and push changes to the Rx
  OnboardingScreen({super.key, required this.onProceed}) {
    _controller.addListener(() {
      _usernameRx.value = _controller.text.trim();
    });
  }

  final _theme = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Explorer'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
                _theme.isDark.value ? Icons.light_mode : Icons.dark_mode),
            onPressed: _theme.toggle,
          )),
        ],
      ),

      // ── 2. Use a scrollable column (prevents overflow) ───────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40), // space under the AppBar

            Icon(Icons.code,
                size: 80, color: Theme.of(context).colorScheme.primary),

            const SizedBox(height: 20),
            Text(
              'Enter GitHub Username',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'e.g., 777razib',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ── TextField ───────────────────────────────────────
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onSubmitted: (_) => _proceed(),
            ),
            const SizedBox(height: 24),

            // ── Proceed Button (now correctly uses the Rx) ───────
            Obx(() => ElevatedButton(
              onPressed: _usernameRx.value.isEmpty ? null : _proceed,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Proceed'),
            )),
          ],
        ),
      ),
    );
  }

  void _proceed() {
    if (_usernameRx.value.isNotEmpty) {
      onProceed(_usernameRx.value);
    }
  }
}