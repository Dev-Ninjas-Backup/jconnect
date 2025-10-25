import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: CustomAppBar(title: 'Forgot Password?'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              width: size,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: AppColors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(12),
                      child: Image.asset(
                        Imagepath.lockImage,
                        fit: BoxFit.cover,
                        height: 90,
                        width: 90,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Select which contact details should we use to reset your password',
                        style: getTextStyle(
                          fontsize: 14,
                          fontweight: FontWeight.w400,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
