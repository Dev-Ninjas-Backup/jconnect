import 'dart:async';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/routes/approute.dart';

class SplashController extends GetxController {
  var progressIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (progressIndex.value < 2) {
        progressIndex.value++;
      } else {
        timer.cancel();
        await _checkLoginStatus();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final loginStatus = await SharedPreferencesHelperController().checkLogin();

    if (loginStatus == true) {
      Get.offAllNamed(AppRoute.navBarScreen);
    } else {
      Get.offAllNamed(AppRoute.onboardingScreen);
    }
  }
}
