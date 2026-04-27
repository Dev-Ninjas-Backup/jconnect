import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class PasswordFields extends StatelessWidget {
  const PasswordFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: getTextStyle(
            fontsize: 14,
            fontweight: FontWeight.w500,
            color: AppColors.secondaryTextColor,
          ),
        ),
        SizedBox(height: 8),
        IntlPhoneField(
          style: getTextStyle(color: AppColors.primaryTextColor),
          dropdownTextStyle: getTextStyle(color: AppColors.primaryTextColor),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Padding(padding: EdgeInsets.all(10.0)),
            hintText: 'Enter your phone number',
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryTextColor),
            ),
            hintStyle: getTextStyle(color: AppColors.secondaryTextColor),
          ),
        ),
      ],
    );
  }
}
