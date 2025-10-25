import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var rememberMe = false.obs;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void login() {
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

    EasyLoading.showSuccess("Login Successful!");
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
