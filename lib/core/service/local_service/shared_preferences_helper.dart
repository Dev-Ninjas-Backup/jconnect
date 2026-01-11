import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelperController extends GetxController {
  static const String _accessTokenKey = 'access_token';
  static const String _accessRowTokenKey = 'token';

  static const String _selectedRoleKey = 'role';
  static const String _emailOrPhoneKey = 'email_or_phone';
  static const String _userIdKey = 'user_id';

  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _userName = 'user_name';
  static const String _phoneNumber = 'phone_number';

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

  //save raw token
  Future<void> saveRowToken(String token) async {
    final String saveToken = token;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessRowTokenKey, saveToken);
    await prefs.setBool('success', true);
  }

  // Retrieve access token
  Future<String?> getAccessRowToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessRowTokenKey);
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
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_accessRowTokenKey);
    await prefs.remove(_selectedRoleKey);
    await prefs.remove(_emailOrPhoneKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.remove('success');
  }

  Future<void> clearAfterLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }

  Future<void> clearUserNamePhone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userName);
    await prefs.remove(_phoneNumber);
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

  Future<void> saveEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  Future<void> saveUserName({
    required String userName,
    required String phoneNumber,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userName, userName);
    await prefs.setString(_phoneNumber, phoneNumber);
  }

  Future<String?> getSavedUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName);
  }

  Future<String?> getSavedPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumber);
  }

  Future<String?> getSavedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<String?> getSavedPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }
}
