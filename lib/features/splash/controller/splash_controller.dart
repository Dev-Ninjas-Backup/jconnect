import 'dart:async';
import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';

class SplashController extends GetxController {
  var progressIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (progressIndex.value < 2) {
        progressIndex.value++;
      } else {
        timer.cancel();
        Get.toNamed(AppRoute.onboardingScreen);
      }
    });
  }
}
