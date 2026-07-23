import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';

class NavBarController extends GetxController {
  var currentIndex = 0.obs;
  var showNavBar = false.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
    // When changing tabs, ensure we pop any deep screens and return to the root shell.
    Get.until((route) => route.settings.name == AppRoute.getNavBarScreen());
  }
}
