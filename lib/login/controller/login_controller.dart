import 'package:get/get.dart';
import '../../cores/network_service.dart';
import '../../models/user.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<GitHubUser?> login(String username) async {
    if (username.trim().isEmpty) {
      error.value = 'Enter a username';
      return null;
    }
    isLoading(true);
    error.value = '';
    try {
      final user = await GitHubApi.getUser(username.trim());
      return user;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading(false);
    }
  }
}