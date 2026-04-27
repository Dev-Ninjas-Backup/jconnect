// ignore_for_file: avoid_print, unused_local_variable, await_only_futures

import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/fcm_notification/fcm_notification_controller.dart';
import 'package:jconnect/features/auth/login/controller/login_controller.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class SignupOtpVerificationController extends GetxController {
  final loginController = Get.put(LoginController());
  var remainingSeconds = 50.obs;
  Timer? timer;
  final authRepository = AuthRepository();
  final SharedPreferencesHelperController pref = Get.put(
    SharedPreferencesHelperController(),
  );
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
      final response = await authRepository.resendEmailOtp(email: email);

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Code resent to your email!');

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
        // await pref.saveToken(token.toString());
        //await pref.saveRowToken(token.toString());
        await pref.saveUserId(response['data']['user']['id'].toString());
        print('DEBUG: Token saved after email verification: $token');
      } else {
        print('DEBUG: No token found in email OTP response: $response');
      }

      isLoading.value = false;
      EasyLoading.dismiss();

      // Navigate to profile setup screen after email verification
      EasyLoading.showSuccess('Email verified successfully!');
      Future.delayed(Duration(seconds: 2), () async {
        final email = await pref.getSavedEmail();
        final password = await pref.getSavedPassword();
        final fcmToken = await Get.find<FcmNotificationController>().getFreshToken();

        await loginController.performLoginAfterVerification(
          email.toString().trim(),
          password.toString().trim(),
          fcmToken,
        );
        await pref.clearAfterLogin();

        // Get.toNamed(AppRoute.profileSetupScreen);
        //  Get.toNamed(AppRoute.loginScreen);
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
