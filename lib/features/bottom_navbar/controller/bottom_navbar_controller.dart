import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';

class NavBarController extends GetxController {
  var currentIndex = 0.obs;
  var showNavBar = false.obs;
  var isNavBarVisible = true.obs;

  Timer? _scrollTimer;

  void changeIndex(int index) {
    currentIndex.value = index;
    // When changing tabs, ensure we pop any deep screens and return to the root shell.
    Get.until((route) => route.settings.name == AppRoute.getNavBarScreen());
  }

  void handleScrollNotification(ScrollDirection direction) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (direction == ScrollDirection.reverse) {
        if (isNavBarVisible.value) {
          isNavBarVisible.value = false;
        }
      } else if (direction == ScrollDirection.forward) {
        if (!isNavBarVisible.value) {
          isNavBarVisible.value = true;
        }
      }

      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(seconds: 3), () {
        if (!isNavBarVisible.value) {
          isNavBarVisible.value = true;
        }
      });
    });
  }

  @override
  void onClose() {
    _scrollTimer?.cancel();
    super.onClose();
  }
}
