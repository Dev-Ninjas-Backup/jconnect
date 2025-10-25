import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/routes/approute.dart';

class SignupController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  RxBool isTermsAccepted = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  void toggleTermsAcceptance(bool? value) {
    isTermsAccepted.value = value ?? false;
  }

  Future<void> onContinuePressed() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty) {
      EasyLoading.showError('Full name cannot be empty');
      return;
    }

    if (email.isEmpty) {
      EasyLoading.showError('Email address cannot be empty');
      return;
    }

    if (password.length < 6) {
      EasyLoading.showError('Password must be at least 6 characters long');
      return;
    }

    if (password != confirmPassword) {
      EasyLoading.showError('Passwords do not match');
      return;
    }

    if (!isTermsAccepted.value) {
      EasyLoading.showError('Please accept the Terms and Conditions');
      return;
    }

    EasyLoading.dismiss();
    EasyLoading.showInfo('Verify your phone Number');
    Get.toNamed(AppRoute.phoneVerification);
  }
}
