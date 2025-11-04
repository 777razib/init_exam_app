/*

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../feature/auth/login/model/rider_model.dart';

class AuthController {
  static String? accessToken;
  static RiderModel? userModel;
  static String? accessKey;

  static const String _userIdKey = 'userId';
  static const String _carTransportKey = 'carTransportId';
  static const String _accessTokenKey = 'access-token';
  static const String _userDataKey = 'user-data';

  /// Save token + user model
  static Future<void> setUserData(String token, RiderModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(model.toJson()));

    // Save RiderModel user ID
    if (model.id != null && model.id!.isNotEmpty) {
      await prefs.setString(_userIdKey, model.id!);
    }

    accessToken = token;
    userModel = model;
  }

  /// Load user data from local storage
  static Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final userData = prefs.getString(_userDataKey);

    if (userData != null) {
      accessToken = token;
      userModel = RiderModel.fromJson(jsonDecode(userData));
    }
  }

  /// Save Rider user ID separately (optional)
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  /// Get Rider user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Save CarTransport ID
  static Future<void> saveCarTransportId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_carTransportKey, id);
    print("✅ CarTransport ID saved: $id");
  }

  /// Get CarTransport ID
  static Future<String?> getCarTransportId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_carTransportKey);
    print("📦 CarTransport ID retrieved: $id");
    return id;
  }

  /// Check login status
  static Future<bool> isUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    if (token != null) {
      await getUserData();
      return true;
    }
    return false;
  }

  /// Logout → clear all saved data
  static Future<void> dataClear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    accessToken = null;
    userModel = null;
    accessKey = null;
  }



  /// Clear only CarTransport ID
  static Future<void> carTransportClear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_carTransportKey);
    await prefs.remove(_userIdKey);
    print("🗑️ CarTransport ID cleared");
  }
  static Future<void> idClear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.remove(_userIdKey);
    accessKey = null;
  }
}
*/
