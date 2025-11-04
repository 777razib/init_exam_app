// lib/core/services_class/shared_preferences_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Keys
  static const String _accessTokenKey = 'token';
  static const String _userTypeKey = 'userType';
  static const String _userIdKey = 'userId';
  static const String _isLoginKey = 'isLogin';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _pickerLocationUuidKey = 'pickerLocationUuid';

  // Save Access Token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setBool(_isLoginKey, true);
  }

  // Get Access Token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Save User ID
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  // Get User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save User Type
  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
  }

  // Get User Type
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Check Login Status
  static Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  // Clear All Data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Clear Access Token Only
  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_isLoginKey);
  }

  // Save Picker Location UUID
  static Future<void> savePickerLocationUuid(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pickerLocationUuidKey, uuid);
  }

  // Get Picker Location UUID
  static Future<String?> getPickerLocationUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pickerLocationUuidKey);
  }

  // Save Theme
  static Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDark);
  }

  // Get Theme
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false; // default: light
  }
}