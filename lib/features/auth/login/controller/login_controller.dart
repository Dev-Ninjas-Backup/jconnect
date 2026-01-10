// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authRepository = AuthRepository();
  SharedPreferencesHelperController pref =Get.put(SharedPreferencesHelperController());

  var rememberMe = false.obs;
  RxBool isLoading = false.obs;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      EasyLoading.showError("Please enter your email or phone");
      return;
    }

    if (password.isEmpty) {
      EasyLoading.showError("Please enter your password");
      return;
    }

    if (password.length < 6) {
      EasyLoading.showError("Password must be at least 6 characters");
      return;
    }

    await _performLogin(email, password);
  }

  Future<void> _performLogin(String email, String password) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Logging in...');

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      // Extract token and user data from response
      final token = response['data']['token'] ?? '';
      final user = response['data']['user'];
      pref.saveToken(token);
      pref.saveRowToken(token);
      pref.saveUserId(user['id'].toString());

      print('DEBUG: Login Response: $response');
      print('DEBUG: Token: $token');
      print('DEBUG: User: $user');

      if (token.isNotEmpty) {
        EasyLoading.showSuccess('Login successful!');

        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed(AppRoute.navBarScreen);
        });
      } else {
        EasyLoading.showError('Login failed: No token received');
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError('Login failed: $e');
      print('DEBUG: Login error: $e');
    }
  }








  Future<void> performLoginAfterVerification(String email, String password) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Logging in...');

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      // Extract token and user data from response
      final token = response['data']['token'] ?? '';
      final user = response['data']['user'];
      pref.saveToken(token);
      pref.saveRowToken(token);
      pref.saveUserId(user['id'].toString());

      print('DEBUG: Login Response: $response');
      print('DEBUG: Token: $token');
      print('DEBUG: User: $user');

      if (token.isNotEmpty) {
     //   EasyLoading.showSuccess('Login successful!');

        Future.delayed(Duration(seconds: 1), () {
        Get.toNamed(AppRoute.profileSetupScreen);
        });
      } else {
     //   EasyLoading.showError('Login failed: No token received');
      }
    } catch (e) {
      isLoading.value = false;
     // EasyLoading.showError('Login failed: $e');
      print('DEBUG: Login error: $e');
    }
  }






  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
