import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';

void showGradientSnackBar({
  required String title,
  required String message,
}) {
  Get.rawSnackbar(
    backgroundColor: Colors.transparent,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    margin: EdgeInsets.only(
      bottom: 20.h,
      left: 16.w,
      right: 16.w,
    ),
    padding: EdgeInsets.zero,
    messageText: GradientBorderContainer(
      borderRadius: 12,
      borderWidth: 1.5,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      gradientColors: const [
        Color(0xFF60000F),
        Color(0xFFBB0224),
        Color(0xFF60000F),
      ],
      color: const Color(0xFF140E0E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(
              fontsize: 14,
              fontweight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            message,
            style: getTextStyle(
              fontsize: 12,
              fontweight: FontWeight.w400,
              color: AppColors.secondaryTextColor,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    ),
  );
}
