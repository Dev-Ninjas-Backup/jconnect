import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';

class StartDeal extends StatelessWidget {
  final HomeController controller;
  const StartDeal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.startDealList.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Container(
              width: 310.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFBD001F),
                    Color(0xFF713AE6).withValues(alpha: .5),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🔥 Weekend Deal – 10% Off on All Deals!",
                        style: getTextStyle(
                          fontweight: FontWeight.w600,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
                        style: getTextStyle(
                          fontsize: sp(10),
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomPrimaryButton(
                        buttonText: "Start Deal",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
