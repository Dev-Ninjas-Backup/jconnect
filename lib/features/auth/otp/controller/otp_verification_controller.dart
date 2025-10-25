import 'dart:async';
import 'package:get/get.dart';

class OtpVerificationController extends GetxController {
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
}
