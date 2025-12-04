import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';

class PhoneVerificationController extends GetxController {
  var remainingSeconds = 50.obs;
  Timer? timer;
  final authRepository = AuthRepository();
  RxBool isLoading = false.obs;

  late String phone;
  late String resetToken;
  late bool isFromSignup;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from SignupOtpVerificationController or other screens
    final arguments = Get.arguments as Map<String, dynamic>?;
    phone = arguments?['phone'] ?? '';
    resetToken = arguments?['resetToken'] ?? '';
    isFromSignup = arguments?['fromSignup'] ?? false;
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

      // Call the send phone OTP endpoint to resend OTP to phone
      await authRepository.sendPhoneOtp(phone: phone);

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Code resent to your phone!');
      startTimer();

      print('DEBUG: Phone OTP resent to $phone');
    } catch (e) {
      EasyLoading.showError('Failed to resend code: $e');
      print('DEBUG: Resend phone code error: $e');
    }
  }

  Future<void> verifyPhoneOtp(int phoneOtp) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Verifying phone...');

      await authRepository.verifyPhoneOtp(
        phone: phone,
        otp: phoneOtp,
        resetToken: resetToken,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      // Navigate to profile setup or home based on flow
      if (isFromSignup) {
        EasyLoading.showSuccess('Account created successfully!');
        Future.delayed(Duration(seconds: 1), () {
          Get.toNamed(AppRoute.profileSetupScreen);
        });
      } else {
        EasyLoading.showSuccess('Phone verified!');
        Future.delayed(Duration(seconds: 1), () {
          Get.toNamed(AppRoute.profileSetupScreen);
        });
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError('Phone verification failed: $e');
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
