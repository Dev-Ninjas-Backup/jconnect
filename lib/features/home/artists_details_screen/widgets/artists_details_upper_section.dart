import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/constants/imagepath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_app_bar2.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
import '../../../../core/common/widgets/custom_secondary_button.dart';

class ArtistsDetailsUpperSection extends StatelessWidget {
  const ArtistsDetailsUpperSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAppBar2(
          title: "Artist Details",
          leadingIconUrl: Iconpath.backIcon,
          onLeadingTap: () {
            Get.back();
          },
        ),
        SizedBox(height: 34.h),
    
        Center(
          child: Column(
            children: [
              Image.asset(
                Imagepath.profileImage,
                height: 130.w,
                width: 130.w,
              ),
              SizedBox(height: 12.h),
              Text(
                "DJ NovaX",
                style: getTextStyle(
                  fontsize: sp(24),
                  fontweight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Music Reviewer • Club DJ • Producer",
                style: getTextStyle(
                  fontsize: sp(10),
                  fontweight: FontWeight.w400,
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .7,
                  ),
                ),
              ),
            ],
          ),
        ),
    
        SizedBox(height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 24.w,
          children: [
            // GestureDetector(
            //   onTap: () {},
            //   child: Expanded(
            //     child: GradientBorderContainer(
            //       borderRadius: 6.r,
            //       borderWidth: 0.75,
            //       gradientColors: [
            //         AppColors.primaryTextColor,
            //         AppColors.primaryTextColor.withValues(alpha: .50),
            //       ],
            //       padding: EdgeInsets.symmetric(
            //         horizontal: 10.w,
            //         vertical: 10.h,
            //       ),
            //       child: Center(
            //         child: Text(
            //           "Message",
            //           style: getTextStyle(
            //             fontsize: sp(14),
            //             fontweight: FontWeight.w400,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: CustomSecondaryButton(
                buttonText: "Message",
                onTap: () {},
              ),
            ),
            Expanded(
              child: CustomPrimaryButton(
                buttonText: "Request Service",
                onTap: () {},
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 40.h),
        Text(
          "Social Links:",
          style: getTextStyle(
            fontsize: sp(18),
            fontweight: FontWeight.w500,
            color: AppColors.primaryTextColor.withValues(alpha: .7),
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Image.asset(Iconpath.instagram, height: 20.h, width: 20.w),
            SizedBox(width: 36.w),
            Image.asset(Iconpath.facebook, height: 20.h, width: 20.w),
            SizedBox(width: 36.w),
            Image.asset(Iconpath.tiktok, height: 20.h, width: 20.w),
            SizedBox(width: 36.w),
            Image.asset(Iconpath.youtube, height: 20.h, width: 28.w),
          ],
        ),
        SizedBox(height: 40.h),
        Text(
          "About DJ NovaX",
          style: getTextStyle(
            fontsize: sp(18),
            fontweight: FontWeight.w500,
            color: AppColors.primaryTextColor.withValues(alpha: .7),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Multi-genre DJ and producer known for blending deep house and electro with cinematic soundscapes. Based in Miami, performing worldwide.",
          style: getTextStyle(
            fontsize: sp(12),
            color: AppColors.primaryTextColor.withValues(alpha: .5),
          ),
        ),
      ],
    );
  }
}