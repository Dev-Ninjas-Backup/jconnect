import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class PhoneVerificationController extends GetxController {
  var remainingSeconds = 50.obs;
  Timer? timer;

  @override
  void onInit() {
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
    // TODO: Add resend logic here
    startTimer();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void createAccount() {
    EasyLoading.dismiss();
    EasyLoading.show(status: 'Creating your account...');

    Future.delayed(const Duration(seconds: 2));
    // Get.toNamed(AppRoute.profileSetup);
  }
}
