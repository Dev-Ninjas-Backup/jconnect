import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_obsecure_textfield.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/auth/login/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final controller = TextEditingController();
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: .4)),
          ),

          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Image.asset(
              Imagepath.redCircleGlow,
              width: size.width * 0.9,
            ),
          ),

          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Welcome back to the Beat.",
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 24,
                    fontweight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Log in and pick up where your collabs left off.",
                  style: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Email field
          Positioned(
            top: size.height * 0.38,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email or Phone",
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextfield(
                  controller: controller.emailController,
                  hintText: 'Enter your email or phone number',
                ),
              ],
            ),
          ),

          // Password field
          Positioned(
            top: size.height * 0.50,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password",
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                CustomObsecureTextfield(
                  controller: controller.passwordController,
                ),
                const SizedBox(height: 12),

                // Remember me + Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: controller.toggleRememberMe,
                            activeColor: AppColors.redColor,
                          ),
                          Text(
                            "Remember me",
                            style: getTextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoute.forgetPassword);
                      },
                      child: Text(
                        "Forgot Password?",
                        style: getTextStyle(
                          color: AppColors.redColor,
                          fontsize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Login button
          Positioned(
            top: size.height * 0.70,
            left: 20,
            right: 20,
            child: CustomPrimaryButton(
              buttonText: "Login",
              onTap: controller.login,
            ),
          ),

          // Social buttons
          Positioned(
            top: size.height * 0.80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "or",
                  style: getTextStyle(color: AppColors.primaryTextColor),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(Iconpath.googleIcon, height: 40),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(Iconpath.facebookIcon, height: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Signup text
          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: "Don’t have an account? ",
                  style: getTextStyle(color: AppColors.primaryTextColor),
                  children: [
                    TextSpan(
                      text: "Signup",
                      style: getTextStyle(
                        color: AppColors.redColor,
                        fontweight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
