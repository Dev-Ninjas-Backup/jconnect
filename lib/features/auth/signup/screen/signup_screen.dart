import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/custom_obsecure_textfield.dart';
import 'package:jconnect/features/auth/signup/controller/signup_controller.dart';
import 'package:jconnect/features/auth/signup/widgets/checkbox_widget.dart';
import 'package:jconnect/features/auth/signup/widgets/phone_field_widget.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Start your journey in sound.",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 22,
                  fontweight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Log in and pick up where your collabs left off.",
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 14,
                  fontweight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "Full Name",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
              ),
              const SizedBox(height: 6),
              CustomTextfield(
                hintText: "Enter your full name",
                controller: controller.fullNameController,
              ),

              const SizedBox(height: 20),

              // Email
              Text(
                "Email Address",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
              ),
              const SizedBox(height: 6),
              CustomTextfield(
                hintText: "Enter your address",
                controller: controller.emailController,
              ),

              const SizedBox(height: 20),

              Text(
                "Phone Number",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
              ),
              const SizedBox(height: 6),
              PhoneFieldWidget(controller: controller),

              const SizedBox(height: 10),

              Text(
                "Create Password",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
              ),
              const SizedBox(height: 6),
              CustomObsecureTextfield(
                controller: controller.passwordController,
              ),

              const SizedBox(height: 20),

              Text(
                "Confirm Password",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
              ),
              const SizedBox(height: 6),
              CustomObsecureTextfield(
                controller: controller.confirmPasswordController,
              ),

              const SizedBox(height: 16),

              CheckBoxWidget(controller: controller),
              const SizedBox(height: 24),

              CustomPrimaryButton(
                buttonText: "Continue",
                onTap: controller.onContinuePressed,
              ),

              SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    Text(
                      "or Create Account with",
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontsize: 13,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialCircle(Iconpath.googleIcon),
                        SizedBox(width: 24),
                        _socialCircle(Iconpath.facebookIcon),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: getTextStyle(
                            color: AppColors.secondaryTextColor,
                            fontsize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            "Login",
                            style: getTextStyle(
                              color: AppColors.redColor,
                              fontsize: 13,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialCircle(String path) {
    return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1E1E1E),
      ),
      child: Image.asset(path, fit: BoxFit.fill),
    );
  }
}
