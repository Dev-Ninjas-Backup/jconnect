import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void showGradientSnackBar({
  required String title,
  required String message,
  SnackPosition snackPosition = SnackPosition.TOP,
  Duration duration = const Duration(seconds: 1),
}) {
  EasyLoading.showToast(
    "$title\n$message",
    duration: duration,
    toastPosition: snackPosition == SnackPosition.BOTTOM
        ? EasyLoadingToastPosition.bottom
        : EasyLoadingToastPosition.top,
  );
}
