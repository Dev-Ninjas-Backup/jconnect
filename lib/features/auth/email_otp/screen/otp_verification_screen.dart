import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/auth/email_otp/controller/otp_verification_controller.dart';
import 'package:jconnect/features/auth/email_otp/widget/otp_field.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpVerificationController());
    final otpController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: CustomAppBar(title: 'Forgot Password'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Code has been sent to ${controller.email}',
              style: getTextStyle(
                fontsize: 15,
                fontweight: FontWeight.w400,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 40),

            OTPfield(otpControllers: [otpController]),

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
                      color: AppColors.secondaryTextColor,
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

            Obx(
              () => CustomPrimaryButton(
                buttonText: controller.isLoading.value
                    ? 'Verifying...'
                    : 'Verify',
                onTap: controller.isLoading.value
                    ? () {}
                    : () {
                        controller.verifyOtp(otpController.text);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
