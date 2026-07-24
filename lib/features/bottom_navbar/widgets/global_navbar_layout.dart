import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/bottom_navbar/controller/bottom_navbar_controller.dart';

class GlobalNavBarLayout extends StatelessWidget {
  final Widget child;

  const GlobalNavBarLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final NavBarController controller = Get.put(NavBarController());

    final List<String> icons = [
      Iconpath.homeIcon,
      Iconpath.messagesIcon,
      Iconpath.searchIcon,
      Iconpath.orderIcon,
      Iconpath.profileIcon,
    ];

    final List<String> labels = [
      "Home",
      "Messages",
      "Search",
      "Orders",
      "Profile",
    ];

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          controller.handleScrollNotification(notification.direction);
          return false;
        },
        child: child,
      ), // This is the root navigator containing the app's screens
      bottomNavigationBar: Obx(() => controller.showNavBar.value
          ? AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: controller.isNavBarVisible.value
                  ? Container(
                      decoration: BoxDecoration(color: AppColors.backGroundColor),
                      padding: EdgeInsets.only(
                        left: 30.w,
                        right: 30.w,
                        bottom: 46.h,
                        top: 12.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(icons.length, (index) {
                          bool isSelected = controller.currentIndex.value == index;
                          return GestureDetector(
                            onTap: () => controller.changeIndex(index),
                            child: Container(
                              color: Colors.transparent, // expand tap area
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    icons[index],
                                    width: 24.w,
                                    height: 24.h,
                                    color: isSelected
                                        ? AppColors.primaryTextColor
                                        : AppColors.secondaryTextColor,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    labels[index],
                                    style: getTextStyle(
                                      fontsize: sp(10),
                                      fontweight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryTextColor
                                          : AppColors.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            )
          : const SizedBox.shrink()),
    );
  }
}
