import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';

void showDeleteDialogCustomService() {
  Get.bottomSheet(
    Container(
      height: 565.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primaryTextColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 14.h),

          Image.asset(Imagepath.illustration, height: 208.w, width: 208.w),
          SizedBox(height: 40.h),
          Text(
            "Your request has been sent!",
            style: getTextStyle(
              fontsize: sp(20),
              fontweight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "You’ll get a notification when the artist replies with a custom offer.",
            textAlign: TextAlign.center,
            style: getTextStyle(color: Color(0xFFA3A3A3)),
          ),
          SizedBox(height: 42.h),
          CustomPrimaryButton(buttonText: "View Request", onTap: () {}),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
