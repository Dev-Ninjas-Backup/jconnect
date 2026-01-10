import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/payment/payment_controller.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileSettingsSection extends StatelessWidget {
  final ProfileController controller;
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  ProfileSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Settings & Preferences',
              style: getTextStyle(
                color: Colors.white,
                fontweight: FontWeight.w600,
                fontsize: 18,
              ),
            ),
          ),
          Divider(color: Colors.grey, thickness: 0.15, height: 0),

          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile Details',
            onTap: () {
              Get.toNamed(AppRoute.editProfileScreen);
            },
          ),
          _buildSettingsTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Method',
            onTap: () async {
              EasyLoading.show(status: 'Checking payment methods...');
              try {
                final prefs = Get.find<SharedPreferencesHelperController>();
                final token = await prefs.getAccessToken();
                EasyLoading.dismiss();
                if (token == null || token.isEmpty) {
                  // No auth — go to add stripe
                  Get.toNamed(AppRoute.addStripe);
                  return;
                }

                final authHeader = token.startsWith('Bearer ')
                    ? token
                    : 'Bearer $token';
                final resp = await http.get(
                  Uri.parse(Endpoint.getPaymentMethods),
                  headers: {
                    'Authorization': authHeader,
                    'Content-Type': 'application/json',
                  },
                );

                if (resp.statusCode >= 200 && resp.statusCode < 300) {
                  final body = resp.body.trim();
                  if (body.isEmpty || body == '[]' || body == '{}') {
                    Get.toNamed(AppRoute.addStripe);
                    return;
                  }

                  try {
                    final jsonBody = json.decode(resp.body);
                    // If server returned an object with paymentMethod or id, go to manage
                    if (jsonBody is Map &&
                        (jsonBody['paymentMethod'] != null ||
                            jsonBody['id'] != null)) {
                      // Ensure PaymentController is registered before navigating
                      try {
                        if (!Get.isRegistered<PaymentController>()) {
                          Get.put(PaymentController());
                        }
                      } catch (_) {
                        // Fallback: attempt to put controller (non-fatal)
                        try {
                          Get.put(PaymentController());
                        } catch (__) {}
                      }

                      Get.toNamed(AppRoute.manageViaStripe);
                    } else {
                      Get.toNamed(AppRoute.addStripe);
                    }
                  } catch (_) {
                    // Non-JSON or unexpected body — fallback to add
                    Get.toNamed(AppRoute.addStripe);
                  }
                } else if (resp.statusCode == 404) {
                  Get.toNamed(AppRoute.addStripe);
                } else {
                  // Other errors — show message and fallback to add
                  Get.snackbar(
                    'Error',
                    'Failed to check payment method (${resp.statusCode})',
                  );
                  Get.toNamed(AppRoute.addStripe);
                }
              } catch (e) {
                EasyLoading.dismiss();
                Get.snackbar('Error', 'Unable to check payment method');
                Get.toNamed(AppRoute.addStripe);
              }
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Get.toNamed('/notificationScreen');
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () {
              Get.toNamed(AppRoute.privacySecurity);
            },
          ),
          _buildSettingsTile(
            icon: Icons.headset_mic_outlined,
            title: 'Help & Support',
            onTap: () {
              Get.toNamed(AppRoute.helpAndSupportScreen);
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            isLogout: true,
            onTap: () async {
              await pref.clearAllData();
              Get.offAllNamed('/loginScreen');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(
        icon,
        color: isLogout ? AppColors.redColor : AppColors.primaryTextColor,
      ),
      title: Text(
        title,
        style: getTextStyle(
          color: isLogout ? AppColors.redColor : AppColors.primaryTextColor,
          fontweight: FontWeight.w500,
          fontsize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }
}
