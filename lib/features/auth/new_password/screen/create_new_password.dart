import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_obsecure_textfield.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/auth/new_password/controller/create_password_controller.dart';

class CreateNewPassword extends StatelessWidget {
  CreateNewPassword({super.key});

  final controller = Get.put(CreatePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: CustomAppBar(title: 'Create New Password'),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              'Create your new password',
              style: getTextStyle(
                fontsize: 14,
                fontweight: FontWeight.w500,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            CustomObsecureTextfield(controller: controller.passwordController),
            SizedBox(height: 12),
            Text(
              'Confirm Your Password',
              style: getTextStyle(
                fontsize: 14,
                fontweight: FontWeight.w500,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 12),
            CustomObsecureTextfield(
              controller: controller.confirmPasswordController,
            ),
            Spacer(),
            CustomPrimaryButton(
              buttonText: 'Continue',
              onTap: () {
                controller.submitPassword();
              },
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
