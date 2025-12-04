import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';

class SignupController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authRepository = AuthRepository();
  RxBool isLoading = false.obs;
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
    final phone = phoneController.text.trim();
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

    if (phone.isEmpty) {
      EasyLoading.showError('Phone number cannot be empty');
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

    await _registerUser(fullName, email, phone, password);
  }

  Future<void> _registerUser(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Registering...');

      final response = await authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      // Extract resetToken from response data
      String resetToken = '';
      if (response['data'] != null && response['data'] is Map) {
        resetToken = response['data']['resetToken'] ?? '';
      }

      print('DEBUG: Registration Response: $response');
      print('DEBUG: Reset Token extracted: $resetToken');

      // Store registration data for next screens
      Get.find<SignupController>().emailController.text = email;
      Get.find<SignupController>().phoneController.text = phone;

      // Navigate to email OTP verification screen
      Get.toNamed(
        AppRoute.signupOtpVerification,
        arguments: {'email': email, 'phone': phone, 'resetToken': resetToken},
      );
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError('Registration failed: $e');
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
