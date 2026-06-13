import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';

class RepostContentPaymentScreen extends StatelessWidget {
  const RepostContentPaymentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar2(
              title: 'Content & Payment',
              leadingIconUrl: Iconpath.backIcon,
              onLeadingTap: () {
                Get.back();
              },
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Share Link",
                        style: getTextStyle(
                          color: AppColors.primaryTextColor,
                          fontsize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextfield(
                        hintText: "Enter your Share Link",
                        controller: TextEditingController(),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF60000F),
                                Color(0xFFBB0224),
                                Color(0xFF60000F),
                              ],
                            ),
                          ),
                          child: Text(
                            'Pay Now',
                            style: getTextStyle(
                              fontsize: 14,
                              fontweight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
