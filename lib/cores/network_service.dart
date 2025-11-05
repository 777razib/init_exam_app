import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/repo.dart';

class GitHubApi {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/vnd.github.v3+json'},
  ));

  static Future<GitHubUser> getUser(String username) async {
    try {
      final response = await _dio.get('/users/$username');
      return GitHubUser.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User "$username" not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout');
      }
      throw Exception('Failed to load user: ${e.message}');
    }
  }

  static Future<List<Repository>> getRepos(String username) async {
    try {
      final response = await _dio.get('/users/$username/repos', queryParameters: {'per_page': 100});
      return (response.data as List).map((e) => Repository.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User "$username" not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Rate limit exceeded. Please try again later.');
      }
      throw Exception('Failed to load repos: ${e.message}');
    }
  }
}