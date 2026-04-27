import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/auth/phone_verification/controller/phone_verification_controller.dart';

class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneVerificationController());
    final pinputController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: CustomAppBar(title: 'Verification'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Verify your Phone Number',
              style: getTextStyle(
                fontsize: 22,
                fontweight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            Text(
              'Code has been sent to ${controller.phone}',
              style: getTextStyle(
                fontsize: 15,
                fontweight: FontWeight.w400,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 40),

            Pinput(
              controller: pinputController,
              length: 4,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              showCursor: true,
              onCompleted: (pin) {
                controller.verifyPhoneOtp(int.parse(pin));
              },
              defaultPinTheme: PinTheme(
                width: 60,
                height: 60,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 60,
                height: 60,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.redColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
              ),
              submittedPinTheme: PinTheme(
                width: 60,
                height: 60,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
              ),
            ),

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
              buttonText: 'Verify',
              onTap: () {
                if (controller.isLoading.value) return;
                final phoneOtp = pinputController.text;
                if (phoneOtp.length == 4) {
                  controller.verifyPhoneOtp(int.parse(phoneOtp));
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
}
