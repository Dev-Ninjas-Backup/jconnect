import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:jconnect/routes/approute.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

class RequestCustomServiceCard extends StatelessWidget {
  const RequestCustomServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GradientBorderContainer(
        borderRadius: 8.r,
        borderWidth: .6,
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Iconpath.customReqIcon, height: 20.h, width: 22.5.w),
            SizedBox(height: 8.h),
            Text(
              "Need something custom?",
              style: getTextStyle(
                fontsize: sp(14),
                fontweight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Didn't find exactly what you're looking for? Send a custom request and let the artist create something tailored for you.",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: sp(12),
                color: AppColors.primaryTextColor.withValues(alpha: .6),
              ),
            ),
            SizedBox(height: 40.h),

            CustomPrimaryButton(
              buttonText: "Request a Custom Service",
              onTap: () {
                Get.toNamed(AppRoute.customServices);
              },
            ),
          ],
        ),
      ),
    );
  }
}
