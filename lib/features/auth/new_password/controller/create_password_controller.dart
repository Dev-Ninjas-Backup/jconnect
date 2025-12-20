import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/auth/new_password/widget/congratulations_dialog_widget.dart';

class CreatePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool validatePasswords() {
    if (oldPasswordController.text.isEmpty) {
      EasyLoading.showError("Old password is required");
      return false;
    }
    if (newPasswordController.text.length < 6) {
      EasyLoading.showError("New password must be at least 6 characters");
      return false;
    }
    return true;
  }

  Future<void> submitPassword() async {
    if (!validatePasswords()) return;

    EasyLoading.show(status: "Updating password...");

    try {
      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError("Authentication token not found");
        return;
      }

      final response = await http.put(
        Uri.parse(Endpoint.changePassword),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "old": oldPasswordController.text,
          "newPass": newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        // Clear all local storage
        await prefs.clearAllData();
        // Show success dialog
        Get.dialog(CongratulationsDialog(), barrierDismissible: false);
      } else {
        EasyLoading.showError(
          "Failed to change password: ${response.statusCode}",
        );
      }
    } catch (e) {
      EasyLoading.showError("Something went wrong: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
