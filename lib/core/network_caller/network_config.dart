/*
// lib/core/network_caller/network_config.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:logger/logger.dart';
import '../services_class/shared_preferences_data_helper.dart';

class NetworkResponse {
  final int statusCode;
  final Map<String, dynamic>? responseData;
  final String? errorMessage;
  final bool isSuccess;

  NetworkResponse({
    required this.statusCode,
    this.responseData,
    this.errorMessage = "Request failed!",
    required this.isSuccess,
  });
}

class NetworkCall {
  static final Logger _logger = Logger();
  static final Dio _dio = Dio();

  // Initialize Dio once
  static void init() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Add interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (AuthController.accessToken != null && AuthController.accessToken!.isNotEmpty) {
          options.headers['Authorization'] = AuthController.accessToken!;
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await _logOut();
        }
        handler.next(e);
      },
    ));
  }

  /// POST Multipart
  static Future<NetworkResponse> multipartRequest({
    required String url,
    Map<String, String>? fields,
    Map<String, dynamic>? body,
    File? imageFile,
    File? videoFile,
    required String methodType,
  }) async {
    try {
      FormData formData = FormData();

      // Add fields
      if (fields != null) formData.fields.addAll(fields.entries);
      if (body != null) {
        body.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      // Attach files
      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: 'image.jpg'),
        ));
      }
      if (videoFile != null) {
        formData.files.add(MapEntry(
          'video',
          await MultipartFile.fromFile(videoFile.path, filename: 'video.mp4'),
        ));
      }

      _logRequest(url, _dio.options.headers, requestBody: formData.fields);

      Response response = await _dio.request(
        url,
        data: formData,
        options: Options(method: methodType),
      );

      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: true,
          responseData: response.data is Map ? response.data : jsonDecode(response.data),
        );
      } else {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: false,
          responseData: response.data is Map ? response.data : jsonDecode(response.data),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await _logOut();
      return NetworkResponse(
        statusCode: e.response?.statusCode ?? -1,
        isSuccess: false,
        errorMessage: e.message ?? e.toString(),
        responseData: e.response?.data,
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// POST
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _request(
      url: url,
      method: 'POST',
      body: body,
    );
  }

  /// PATCH
  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _request(
      url: url,
      method: 'PATCH',
      body: body,
    );
  }

  /// GET
  static Future<NetworkResponse> getRequest({
    required String url,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      url: url,
      method: 'GET',
      queryParams: queryParams,
    );
  }

  /// PUT
  static Future<NetworkResponse> putRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _request(
      url: url,
      method: 'PUT',
      body: body,
    );
  }

  /// DELETE
  static Future<NetworkResponse> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _request(
      url: url,
      method: 'DELETE',
      body: body,
    );
  }

  /// PUT Multipart
  static Future<NetworkResponse> putMultipartRequest({
    required String url,
    required File file,
    String? fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    try {
      FormData formData = FormData();
      if (fields != null) formData.fields.addAll(fields.entries);
      formData.files.add(MapEntry(
        fieldName!,
        await MultipartFile.fromFile(file.path),
      ));

      _logRequest(url, _dio.options.headers, requestBody: formData.fields);

      Response response = await _dio.put(url, data: formData);
      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: true,
          responseData: response.data is Map ? response.data : jsonDecode(response.data),
        );
      } else {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: false,
          responseData: response.data,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await _logOut();
      return NetworkResponse(
        statusCode: e.response?.statusCode ?? -1,
        isSuccess: false,
        errorMessage: e.message,
        responseData: e.response?.data,
      );
    }
  }

  // Generic Request
  static Future<NetworkResponse> _request({
    required String url,
    required String method,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _logRequest(url, _dio.options.headers, requestBody: body);

      Response response = await _dio.request(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(method: method),
      );

      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: true,
          responseData: response.data is Map ? response.data : jsonDecode(response.data),
        );
      } else {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: false,
          responseData: response.data is Map ? response.data : jsonDecode(response.data),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await _logOut();
      return NetworkResponse(
        statusCode: e.response?.statusCode ?? -1,
        isSuccess: false,
        errorMessage: e.message ?? e.toString(),
        responseData: e.response?.data,
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Logging
  static void _logRequest(String url, Map<String, dynamic> headers, {Map? requestBody}) {
    _logger.i("REQUEST\nURL: $url\nHeaders: $headers\nBody: ${jsonEncode(requestBody)}");
  }

  static void _logResponse(String url, Response response) {
    _logger.i("RESPONSE\nURL: $url\nStatus: ${response.statusCode}\nBody: ${response.data}");
  }

  static Future<void> _logOut() async {
    await AuthController.dataClear();
    //Get.offAll(() => LoginView());
  }
}*/
