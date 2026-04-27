import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/auth/signup/controller/signup_controller.dart';

class PhoneFieldWidget extends StatelessWidget {
  const PhoneFieldWidget({super.key, required this.controller});

  final SignupController controller;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller.phoneController,
      style: getTextStyle(color: AppColors.primaryTextColor, fontsize: 15),
      dropdownTextStyle: getTextStyle(
        color: AppColors.primaryTextColor,
        fontsize: 15,
      ),
      decoration: InputDecoration(
        hintText: 'You have to verify your number',
        hintStyle: getTextStyle(color: Colors.grey, fontsize: 14),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.redColor),
        ),
      ),
      initialCountryCode: 'US',
    );
  }
}
