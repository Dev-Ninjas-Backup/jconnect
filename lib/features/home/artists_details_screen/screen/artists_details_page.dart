import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import '../widgets/artists_details_upper_section.dart';
import '../widgets/review_and_rating.dart';

class ArtistsDetailsPage extends StatelessWidget {
  const ArtistsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ArtistsDetailsController());
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              ArtistsDetailsUpperSection(),
              SizedBox(height: 30.h),

              GradientBorderContainer(
                borderRadius: 8.r,
                borderWidth: .5,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 30.w,
                  children: [
                    Expanded(
                      child: CustomPrimaryButton(
                        buttonText: "Social Post",
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: CustomSecondaryButton(
                        buttonText: "Services",
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              GradientBorderContainer(
                borderRadius: 6.r,
                borderWidth: .5,
                padding: EdgeInsets.symmetric(horizontal: 14.w,vertical: 14.h),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 12.w),
                Text(
                 "item.title",
                  style: getTextStyle(
                    fontsize: sp(16),
                    fontweight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                 "item.subTitle",
                  style: getTextStyle(
                    fontsize: sp(10),
                    fontweight: FontWeight.w400,
                    color: AppColors.primaryTextColor.withValues(
                      alpha: .5,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
    
                  children: [
                    Expanded(
                      child: Text(
                        "\${item.rate}/promotion",
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w400,
                          color: AppColors.primaryTextColor
                              .withValues(alpha: .7),
                        ),
                      ),
                    ),
                    CustomPrimaryButton(
                    
                      buttonHeight: 10.h,
                      buttonWidth: 109.w,
    
                      buttonText: "Request Service",
                      fontSize: sp(10),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
              ),

              //  SocialPost(controller: controller),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Review & Rating",
                    style: getTextStyle(
                      fontsize: sp(18),
                      fontweight: FontWeight.w500,
                      color: AppColors.primaryTextColor.withValues(alpha: .70),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.primaryTextColor,
                        size: sp(14),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "4.8 (32 reviews)",
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w500,
                          color: AppColors.primaryTextColor.withValues(
                            alpha: .70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              ReviewAndRating(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
