// lib/feature/home/repository/home_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../../model/repo_model.dart';
import '../../model/user_model.dart';

class NetworkResponse {
  final int statusCode;
  final bool isSuccess;
  final dynamic responseData;
  final String? errorMessage;

  NetworkResponse({
    required this.statusCode,
    required this.isSuccess,
    this.responseData,
    this.errorMessage,
  });
}

class HomeRepository {
  // API GET method
  Future<NetworkResponse> _get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final status = response.statusCode;

      if (status == 200) {
        final data = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: status,
          isSuccess: true,
          responseData: data,
        );
      } else {
        return NetworkResponse(
          statusCode: status,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Fetch User
  Future<UserModel?> fetchUser(String username) async {
    final response = await _get('https://api.github.com/users/$username');
    if (response.isSuccess) {
      return UserModel.fromJson(response.responseData);
    }
    return null;
  }

  // Fetch Repos
  Future<List<RepoModel>> fetchRepos(String username) async {
    final response = await _get('https://api.github.com/users/$username/repos');
    if (response.isSuccess) {
      final List<dynamic> data = response.responseData;
      return data.map((json) => RepoModel.fromJson(json)).toList();
    }
    return [];
  }
}
// lib/feature/home/controller/home_controller.dart




class HomeController extends GetxController {
  final HomeRepository _repository = HomeRepository();

  final Rx<UserModel> user = UserModel.empty().obs;
  final RxList<RepoModel> repos = <RepoModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // Filters
  final RxString filterBy = 'name'.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  Future<void> fetchUserAndRepos(String username) async {
    isLoading.value = true;
    error.value = '';

    try {
      final userData = await _repository.fetchUser(username);
      final repoData = await _repository.fetchRepos(username);

      if (userData != null) {
        user.value = userData;
      } else {
        error.value = 'User not found';
      }

      repos.value = repoData;
    } catch (e) {
      error.value = 'Network error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateFilter(String? value) {
    if (value != null) filterBy.value = value;
  }

  void updateDateRange(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
  }
}