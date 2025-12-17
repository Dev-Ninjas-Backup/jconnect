import 'dart:async';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/home/notification/controller/notification_controller.dart';
import 'package:jconnect/routes/approute.dart';

class SplashController extends GetxController {
  final pref = Get.put(SharedPreferencesHelperController());
  final notificationController = Get.put(NotificationController());

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

  // Future<void> _checkLoginStatus() async {
  //   final token = await pref.getAccessToken();
  //   final loginStatus = await pref.checkLogin();

  //   if (loginStatus == true) {
  //     notificationController.connectSocket(token ?? "");

  //     Get.offAllNamed(AppRoute.navBarScreen);
  //     print("=================$token ===========");
  //   } else {
  //     Get.offAllNamed(AppRoute.onboardingScreen);
  //   }
  // }



Future<void> _checkLoginStatus() async {
  final tokenRow = await pref.getAccessRowToken();
    final token = await pref.getAccessToken();

    print("==================$tokenRow ===========");
    print(" ==================$token ===========");

  final loginStatus = await pref.checkLogin();

  if (loginStatus == true && token != null) {
    Get.offAllNamed(AppRoute.navBarScreen);

    // Delay to avoid lifecycle disconnect
    Future.delayed(const Duration(milliseconds: 300), () {
      notificationController.connectSocket(tokenRow ?? " ");
    });
  } else {
    Get.offAllNamed(AppRoute.onboardingScreen);
  }
}




}
