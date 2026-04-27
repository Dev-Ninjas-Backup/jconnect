import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/routes/approute.dart';

class OnboardingMainWidget extends StatelessWidget {
  final String image, title, subtitle, buttonText;
  final VoidCallback onPressed;

  const OnboardingMainWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 260),
          SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 22,
              fontweight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: getTextStyle(color: AppColors.primaryTextColor),
          ),
          SizedBox(height: 40),

          CustomPrimaryButton(buttonText: buttonText, onTap: onPressed),
          SizedBox(height: 10),
          if (buttonText != 'Get Started')
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoute.loginScreen);
              },
              child: Text(
                'Skip',
                style: getTextStyle(color: AppColors.primaryTextColor),
              ),
            ),
        ],
      ),
    );
  }
}
