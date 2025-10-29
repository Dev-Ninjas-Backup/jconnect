import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/imagepath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

class ReqestServiceCard extends StatelessWidget {
  const ReqestServiceCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 9.r,
      borderWidth: .6,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        spacing: 8.w,
        children: [
          Image.asset(
            Imagepath.profileImage,
            height: 48.w,
            width: 48.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //sonic+ rating
                Text(
                  "Track Review by DJ Nova",
                  style: getTextStyle(fontweight: FontWeight.w500),
                ),
                Text(
                  "@djnova",
                  style: getTextStyle(
                    fontsize: sp(12),
                    color: AppColors.primaryTextColor.withValues(
                      alpha: .5,
                    ),
                  ),
                ),
    
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_border_outlined,
                          size: sp(14),
                          color: AppColors.primaryTextColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "4.9",
                          style: getTextStyle(
                            fontsize: sp(12),
                            color: AppColors.primaryTextColor,
                            fontweight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
    
                        Text(
                          "(124 reviews)",
                          style: getTextStyle(
                            fontsize: sp(12),
                            color: AppColors.primaryTextColor
                                .withValues(alpha: .7),
                            fontweight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "\$75",
                      style: getTextStyle(
                        fontsize: sp(16),
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
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
