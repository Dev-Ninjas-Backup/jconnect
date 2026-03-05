import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/auth/forget_password/controller/forget_password_controller.dart';
import 'package:jconnect/features/auth/forget_password/widget/password_fields.dart';
import 'package:jconnect/features/auth/forget_password/widget/top_container.dart';
import 'package:jconnect/routes/approute.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    final size = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: CustomAppBar(title: 'Forgot Password'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TopContainer(size: size),

            SizedBox(height: 45),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton(
                    title: 'Email',
                    isActive: controller.isEmailSelected.value,
                    onTap: controller.selectEmail,
                  ),
                  // const SizedBox(width: 12),
                  // _buildToggleButton(
                  //   title: 'Phone',
                  //   isActive: !controller.isEmailSelected.value,
                  //   onTap: controller.selectPhone,
                  // ),
                ],
              ),
            ),

            SizedBox(height: 35),

            Obx(() {
              if (controller.isEmailSelected.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: getTextStyle(
                        fontsize: 14,
                        fontweight: FontWeight.w500,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: getTextStyle(color: AppColors.primaryTextColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintStyle: getTextStyle(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return PasswordFields();
              }
            }),

            Spacer(),
            Obx(
              () => CustomPrimaryButton(
                buttonText: controller.isLoading.value
                    ? 'Please wait...'
                    : 'Continue',
                onTap: controller.isLoading.value
                    ? () {}
                    : () {
                        if (controller.isEmailSelected.value) {
                          controller.sendForgotPasswordEmail();
                        } else {
                          Get.toNamed(AppRoute.otpVerificationScreen);
                        }
                      },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.redColor : Colors.transparent,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: getTextStyle(
            color: isActive ? Colors.white : AppColors.secondaryTextColor,
            fontweight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
