import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/auth/signup_otp_verification/controller/signup_otp_verification_controller.dart';

class SignupOtpVerificationScreen extends StatelessWidget {
  const SignupOtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupOtpVerificationController());
    final emailOtpControllers = List.generate(
      6,
      (_) => TextEditingController(),
    );

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: CustomAppBar(title: 'Verify Email'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Verify your Email',
              style: getTextStyle(
                fontsize: 22,
                fontweight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Code has been sent to ${controller.email}',
              style: getTextStyle(
                fontsize: 15,
                fontweight: FontWeight.w400,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 40),

            // Email OTP field with 6 digits
            _buildEmailOtpField(emailOtpControllers),

            SizedBox(height: 30),

            Obx(
              () => GestureDetector(
                onTap: controller.remainingSeconds.value == 0
                    ? controller.resendCode
                    : null,
                child: RichText(
                  text: TextSpan(
                    text: controller.remainingSeconds.value == 0
                        ? "Resend code"
                        : "Resend code in ",
                    style: getTextStyle(
                      fontsize: 14,
                      fontweight: FontWeight.w400,
                      color: controller.remainingSeconds.value == 0
                          ? AppColors.redColor
                          : AppColors.secondaryTextColor,
                    ),
                    children: controller.remainingSeconds.value > 0
                        ? [
                            TextSpan(
                              text: "${controller.remainingSeconds.value} s",
                              style: getTextStyle(
                                fontsize: 14,
                                fontweight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ),

            Spacer(),

            CustomPrimaryButton(
              buttonText: 'Verify Email',
              onTap: () {
                if (controller.isLoading.value) return;
                final emailOtp = emailOtpControllers.map((c) => c.text).join();
                print('DEBUG: Email OTP entered: $emailOtp');
                print('DEBUG: Email: ${controller.email}');
                print('DEBUG: Reset Token: ${controller.resetToken}');
                if (emailOtp.length == 6) {
                  controller.verifyEmailOtp(emailOtp);
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter complete OTP',
                    backgroundColor: AppColors.redColor,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailOtpField(List<TextEditingController> controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            controller: controllers[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(Get.context!).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(Get.context!).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
