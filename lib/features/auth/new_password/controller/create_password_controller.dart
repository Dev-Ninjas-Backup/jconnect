import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/auth/new_password/widget/congratulations_dialog_widget.dart';

class CreatePasswordController extends GetxController {
  var password = ''.obs;
  var confirmPassword = ''.obs;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool validatePasswords() {
    if (passwordController.text.length < 6) {
      EasyLoading.showError("Password must be at least 6 characters");
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      EasyLoading.showError("Passwords do not match");
      return false;
    }
    return true;
  }

  void submitPassword() {
    if (validatePasswords()) {
      Get.dialog(CongratulationsDialog(), barrierDismissible: false);
    }
  }
}
