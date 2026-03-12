import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home/notification/controller/notification_controller.dart';
import '../../../../routes/approute.dart';
import '../widgets/recent_artists.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    NotificationController notificationController = Get.put(
      NotificationController(),
    );
    controller.refreshHomeData();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => CustomAppBar2(
                  title: "Home",
                  actionIconUrl: Iconpath.notificationIcon,
                  actionOnTap: () {
                    notificationController.markAllAsRead();
                    Get.put(NotificationController());
                    Get.toNamed(AppRoute.notificationScreen);
                  },
                  badgeCount: notificationController.unreadCount.value,
                ),
              ),

              SizedBox(height: 30.h),

              //StartDeal(controller: controller),
              //SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    //  "Artists You Know",
                    "Recent User",
                    style: getTextStyle(
                      fontsize: sp(20),
                      fontweight: FontWeight.w500,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoute.getArtistsScreen());
                    },
                    child: Text(
                      "View all Users",
                      style: getTextStyle(
                        fontsize: sp(12),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              ArtistsYouKnow(controller: controller),
              SizedBox(height: 40.h),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Top Rated Artists",
              //       style: getTextStyle(
              //         fontsize: sp(20),
              //         fontweight: FontWeight.w500,
              //         color: AppColors.primaryTextColor,
              //       ),
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Get.toNamed(AppRoute.getArtistsScreen());
              //       },
              //       child: Text(
              //         "View all artists",
              //         style: getTextStyle(
              //           fontsize: sp(12),
              //           color: AppColors.secondaryTextColor,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // SizedBox(height: 18.h),
              // TopRatedArtists(controller: controller),

              // SizedBox(height: 40.h),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Suggested for You",
              //       style: getTextStyle(
              //         fontsize: sp(20),
              //         fontweight: FontWeight.w500,
              //         color: AppColors.primaryTextColor,
              //       ),
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Get.toNamed(AppRoute.getArtistsScreen());
              //       },
              //       child: Text(
              //         "View all artists",
              //         style: getTextStyle(
              //           fontsize: sp(12),
              //           color: AppColors.secondaryTextColor,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 18.h),
              // SuggestedForYou(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
