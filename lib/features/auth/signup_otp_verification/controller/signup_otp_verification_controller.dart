// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class SignupOtpVerificationController extends GetxController {
  var remainingSeconds = 50.obs;
  Timer? timer;
  final authRepository = AuthRepository();
  final SharedPreferencesHelperController pref = Get.put(SharedPreferencesHelperController());
  RxBool isLoading = false.obs;

  late String email;
  late String phone;
  late String resetToken;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from SignupController
    final arguments = Get.arguments as Map<String, dynamic>?;
    email = arguments?['email'] ?? '';
    phone = arguments?['phone'] ?? '';
    resetToken = arguments?['resetToken'] ?? '';

    print('DEBUG: SignupOtpVerificationController onInit');
    print('DEBUG: Email: $email');
    print('DEBUG: Phone: $phone');
    print('DEBUG: Reset Token: $resetToken');

    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    remainingSeconds.value = 50;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        t.cancel();
      }
    });
  }

  Future<void> resendCode() async {
    try {
      EasyLoading.show(status: 'Resending code...');

      // Call the register endpoint again to resend OTP to email
      final response = await authRepository.register(
        fullName: '', // Not used for resend
        email: email,
        password: '', // Not used for resend
        phone: phone,
      );

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Code resent to your email!');

      // Extract and update resetToken if needed
      if (response['data'] != null && response['data'] is Map) {
        resetToken = response['data']['resetToken'] ?? resetToken;
        print('DEBUG: New Reset Token from resend: $resetToken');
      }

      startTimer();
    } catch (e) {
      EasyLoading.showError('Failed to resend code: $e');
      print('DEBUG: Resend code error: $e');
    }
  }

  Future<void> verifyEmailOtp(String emailOtp) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Verifying email...');

      final response = await authRepository.verifyEmailOtp(
        resetToken: resetToken,
        emailOtp: emailOtp,
      );

      // Extract and save the authentication token
      final token = response['data']?['token'] ?? response['token'];
      if (token != null && token.toString().isNotEmpty) {
        await pref.saveToken(token.toString());
        print('DEBUG: Token saved after email verification: $token');
      } else {
        print('DEBUG: No token found in email OTP response: $response');
      }

      isLoading.value = false;
      EasyLoading.dismiss();

      // Navigate to profile setup screen after email verification
      EasyLoading.showSuccess('Email verified successfully!');
      Future.delayed(Duration(seconds: 1), () {
        Get.toNamed(AppRoute.profileSetupScreen);
      });
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError('Email verification failed: $e');
      print('DEBUG: Email verification error: $e');
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
