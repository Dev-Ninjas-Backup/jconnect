


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/constants/imagepath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

class ConfirmPromotionUpperCard extends StatelessWidget {
  const ConfirmPromotionUpperCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 6.r,
      borderWidth: .6,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //1st row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    Iconpath.instagram,
                    height: 22.h,
                    width: 22.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Instagram",
                    style: getTextStyle(
                      fontsize: sp(16),
                      fontweight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
    
              Text(
                "\$50",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Social Post Promotion",
                style: getTextStyle(
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .5,
                  ),
                ),
              ),
              Text(
                "Fixed service",
                style: getTextStyle(
                  fontsize: sp(12),
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          GradientBorderContainer(
            color: Color(0xFF353434),
            borderRadius: 6.r,
            borderWidth: .6,
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
    
              children: [
                Image.asset(
                  Imagepath.profileImage,
                  height: 48.w,
                  width: 48.w,
                ),
                SizedBox(width: 8.w,),
                Expanded(
    
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Track Review by DJ Nova",
                        style: getTextStyle(
                          fontweight: FontWeight.w500,
                        ),
                      ),
    
                      Text(
                        "@djnova",
                        style: getTextStyle(fontsize: sp(12)),
                      ),
                    ],
                  ),
                ),
    
                Row(
                  children: [
                    Icon(
                      Icons.star_border,
                      color: AppColors.primaryTextColor,
                      size: sp(14),
                    ),
    
                    Text(
                      "4.9",
                      style: getTextStyle(
                        fontsize: sp(12),
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
