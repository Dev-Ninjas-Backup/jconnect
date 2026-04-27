import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/auth/signup/controller/signup_controller.dart';

class CheckBoxWidget extends StatelessWidget {
  final SignupController controller;
  const CheckBoxWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Obx belongs here since we’re observing the controller’s state
    return Obx(
      () => Row(
        children: [
          Checkbox(
            value: controller.isTermsAccepted.value,
            onChanged: controller.toggleTermsAcceptance,
            activeColor: AppColors.redColor,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "I understand and agree to the ",
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 13,
                ),
                children: [
                  TextSpan(
                    text: "Terms and Conditions.",
                    style: getTextStyle(
                      color: AppColors.redColor,
                      fontsize: 13,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
