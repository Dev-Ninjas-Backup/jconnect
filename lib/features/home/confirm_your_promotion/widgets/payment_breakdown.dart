import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

class PaymentBreakDown extends StatelessWidget {
  const PaymentBreakDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 6.r,
      borderWidth: .6,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //1st row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Service Price",
                style: getTextStyle(
                  fontsize: sp(14),
                  fontweight: FontWeight.w400,
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .7,
                  ),
                ),
              ),
              Text(
                "\$150.00",
                style: getTextStyle(
                  fontsize: sp(14),
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .7,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          //2nd row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Platform Fee (10%)",
                style: getTextStyle(
                  fontsize: sp(14),
                  fontweight: FontWeight.w400,
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .7,
                  ),
                ),
              ),
              Text(
                "\$7.00",
                style: getTextStyle(
                  fontsize: sp(14),
                  fontweight: FontWeight.w400,
                  color: AppColors.primaryTextColor.withValues(
                    alpha: .7,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(thickness: .6),
          SizedBox(height: 6),
              
          //total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor,
                ),
              ),
              
              Text(
                "\$157.00",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w400,
                  color: AppColors.primaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
              
          GradientBorderContainer(
            color: Color(0xFF353434),
              
            borderRadius: 4.r,
            borderWidth: .6,
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10.w,
              children: [
                Image.asset(
                  Iconpath.securityIcon,
                  height: 20.h,
                  width: 20.w,
                ),
              
                Expanded(
                  child: Text(
                    "Payment is securely held until both parties confirm completion",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: getTextStyle(
                      fontsize: sp(12),
                      color: AppColors.primaryTextColor.withValues(
                        alpha: .7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
              
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Iconpath.stripeIcon,
                height: 8.h,
                width: 18.w,
                color: AppColors.primaryTextColor,
              ),
              SizedBox(width: 8.w),
              Text(
                "Secured by Stripe",
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
        ],
      ),
    );
  }
}
