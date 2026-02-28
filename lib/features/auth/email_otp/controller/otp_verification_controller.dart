import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:jconnect/routes/approute.dart';

class OtpVerificationController extends GetxController {
  var remainingSeconds = 50.obs;
  var isLoading = false.obs;
  Timer? timer;

  late String resetToken;
  late String email;
  late AuthRepository authRepository;

  @override
  void onInit() {
    authRepository = AuthRepository();
    // Get arguments from route
    final args = Get.arguments;
    if (args != null) {
      resetToken = args['resetToken'] ?? '';
      email = args['email'] ?? '';
    }
    startTimer();
    super.onInit();
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

  void resendCode() {
    startTimer();
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.isEmpty || otp.length != 6) {
      EasyLoading.showError('Please enter a valid 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Verifying OTP...');

      final response = await authRepository.verifyResetOtp(
        resetToken: resetToken,
        emailOtp: otp,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      if (response['success'] == true) {
        final newResetToken = response['data']?['resetToken'];
        EasyLoading.showSuccess(
          response['message'] ?? 'OTP Verified Successfully!',
        );

        Future.delayed(const Duration(seconds: 1), () {
          Get.toNamed(
            AppRoute.newPasswordScreen,
            arguments: {'resetToken': newResetToken, 'email': email},
          );
        });
      } else {
        EasyLoading.showError(response['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong. Please try again.');
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
