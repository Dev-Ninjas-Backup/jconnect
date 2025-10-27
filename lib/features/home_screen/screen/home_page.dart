import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import 'package:jconnect/features/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home_screen/widgets/start_deal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "Home",
                actionIconUrl: Iconpath.notificationIcon,
                actionOnTap: () {},
              ),
              SizedBox(height: 30.h),
              CustomTextfield(
                hintText: "Search artists or influencers…",
                prefixIcon: Icon(
                  Icons.search,
                  size: sp(20),
                  color: AppColors.secondaryTextColor,
                ),
              ),
              SizedBox(height: 30.h),

              StartDeal(controller: controller),
              SizedBox(height: 30.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Artists You Know",
                    style: getTextStyle(
                      fontsize: sp(20),
                      fontweight: FontWeight.w500,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "View all artists",
                      style: getTextStyle(
                        fontsize: sp(12),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              GradientBorderContainer(
                width: 213.w,
                borderRadius: 10.r,
                borderWidth: 1,
                gradientColors: [
                  Colors.white,
                  Colors.white.withValues(alpha: .5),
                ],
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        //  borderRadius: BorderRadiusGeometry.circular(100.r),
                        child: Image.asset(
                          Imagepath.profileImage,
                          height: 80.h,
                          width: 80.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "KIRA SOUL",
                          style: getTextStyle(
                            fontsize: sp(16),
                            fontweight: FontWeight.w500,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                width: .25,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            child: Text(
                              "From \$95",
                              style: getTextStyle(
                                fontsize: sp(8),
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      "Singer • Influencer • Lyric Reviewer",
                      style: getTextStyle(
                        fontsize: sp(10),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Services",
                      style: getTextStyle(
                        fontsize: sp(10),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
                      style: getTextStyle(
                        fontsize: sp(10),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingBarIndicator(
                          rating: 3,
                          itemBuilder: (context, index) =>
                              Icon(Icons.star, color: Color(0xffBD001F)),
                          itemCount: 5,
                          itemSize: 14.0,
                          direction: Axis.horizontal,
                          unratedColor: Color(0xFFD96B7D),
                        ),
                        Text(
                          "4.9 (50 Reviews)",
                          style: getTextStyle(
                            fontsize: sp(10),
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    CustomPrimaryButton(buttonText: "Message", onTap: () {}),
                    SizedBox(height: 14.h),
                    CustomSecondaryButton(
                      buttonText: "Custom Order",
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
