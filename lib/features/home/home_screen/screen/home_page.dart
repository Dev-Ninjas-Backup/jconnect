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
import '../widgets/browse_by_category.dart';
import '../widgets/recent_artists.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());
  final NotificationController notificationController = Get.put(
    NotificationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 74.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => CustomAppBar2(
                  title: "Home",
                  actionIconUrl: Iconpath.notificationIcon,
                  actionOnTap: () {
                    notificationController.markAllAsRead();
                    Get.toNamed(AppRoute.notificationScreen);
                  },
                  badgeCount: notificationController.unreadCount.value,
                ),
              ),

              SizedBox(height: 30.h),

              BrowseByCategorySection(controller: controller),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent User",
                    style: getTextStyle(
                      fontsize: sp(17),
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
            ],
          ),
        ),
      ),
    );
  }
}
