import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:jconnect/routes/approute.dart';

class ForgetPasswordController extends GetxController {
  var isEmailSelected = true.obs;
  var isLoading = false.obs;

  final emailController = TextEditingController();
  final authRepository = AuthRepository();

  /// Stores the resetToken returned from the API
  String? resetToken;

  void selectEmail() => isEmailSelected.value = true;
  void selectPhone() => isEmailSelected.value = false;

  Future<void> sendForgotPasswordEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      EasyLoading.showError('Please enter your email address');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Sending reset email...');

      final response = await authRepository.forgotPassword(email: email);

      isLoading.value = false;
      EasyLoading.dismiss();

      if (response['success'] == true) {
        resetToken = response['data']?['resetToken'];
        EasyLoading.showSuccess(
          response['message'] ?? 'Password reset email sent successfully!',
        );

        Future.delayed(const Duration(seconds: 1), () {
          Get.toNamed(
            AppRoute.otpVerificationScreen,
            arguments: {'resetToken': resetToken, 'email': email},
          );
        });
      } else {
        EasyLoading.showError(
          response['message'] ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong. Please try again.');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
