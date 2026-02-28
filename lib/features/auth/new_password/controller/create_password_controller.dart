import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/auth/repository/auth_repository.dart';
import 'package:jconnect/features/auth/new_password/widget/congratulations_dialog_widget.dart';

class CreatePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final authRepository = AuthRepository();

  late bool isResetMode;
  late String? resetToken;
  late String? email;

  @override
  void onInit() {
    super.onInit();
    // Check if we're in reset password mode (from forgot password flow)
    final args = Get.arguments;
    if (args != null &&
        args is Map &&
        args.containsKey('resetToken') &&
        args.containsKey('email')) {
      isResetMode = true;
      resetToken = args['resetToken'];
      email = args['email'];
    } else {
      isResetMode = false;
      resetToken = null;
      email = null;
    }
  }

  bool validatePasswords() {
    if (!isResetMode && oldPasswordController.text.isEmpty) {
      EasyLoading.showError("Old password is required");
      return false;
    }
    if (newPasswordController.text.isEmpty) {
      EasyLoading.showError("New password is required");
      return false;
    }
    if (newPasswordController.text.length < 6) {
      EasyLoading.showError("Password must be at least 6 characters");
      return false;
    }
    return true;
  }

  Future<void> submitPassword() async {
    if (!validatePasswords()) return;

    if (isResetMode) {
      await _submitResetPassword();
    } else {
      await _submitChangePassword();
    }
  }

  Future<void> _submitResetPassword() async {
    if (resetToken == null || resetToken!.isEmpty) {
      EasyLoading.showError("Reset token not found");
      return;
    }

    EasyLoading.show(status: "Resetting password...");

    try {
      final response = await authRepository.resetPassword(
        resetToken: resetToken!,
        password: newPasswordController.text,
      );

      if (response['success'] == true) {
        EasyLoading.dismiss();
        Get.dialog(
          CongratulationsDialog(isResetMode: true),
          barrierDismissible: false,
        );
      } else {
        EasyLoading.showError(
          response['message'] ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      EasyLoading.showError("Something went wrong: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _submitChangePassword() async {
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
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
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
        Get.dialog(
          CongratulationsDialog(isResetMode: false),
          barrierDismissible: false,
        );
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

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
