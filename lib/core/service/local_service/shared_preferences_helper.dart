import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelperController extends GetxController {
  static const String _accessTokenKey = 'access_token';
  static const String _selectedRoleKey = 'role';
  static const String _emailOrPhoneKey = 'email_or_phone';
  static const String _userIdKey = 'user_id';

  // Save access token
  Future<void> saveToken(String token) async {
    final String saveToken = 'Bearer $token';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, saveToken);
    await prefs.setBool('success', true);
  }

  // Retrieve access token
  Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // ✅ Save email or phone dynamically
  Future<void> saveEmailOrPhone(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check whether it's email or phone and wrap it in a map
    Map<String, dynamic> data;
    if (value.contains('@')) {
      data = {'email': value};
    } else {
      data = {'phone': value};
    }

    String jsonString = jsonEncode(data);
    await prefs.setString(_emailOrPhoneKey, jsonString);
  }

  //  saved email or phone as Map
  Future<Map<String, dynamic>?> getEmailOrPhoneAsMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_emailOrPhoneKey);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  //  Get only the value (email or phone)
  Future<String?> getEmailOrPhoneValue() async {
    final data = await getEmailOrPhoneAsMap();
    if (data == null) return null;

    if (data.containsKey('email')) return data['email'];
    if (data.containsKey('phone')) return data['phone'];
    return null;
  }

  // Clear access token
  Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey); // Clear the token
    await prefs.remove(_selectedRoleKey); // Clear the role
    await prefs.remove('success'); // Clear the login status
    await prefs.remove(_userIdKey);
  }

  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  //save role
  Future<void> saveSelectedRole(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedRoleKey, role);
  }

  // Retrieve selected role
  Future<String?> getSelectedRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRoleKey);
  }

  Future<bool?> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("success") ?? false;
  }
}
