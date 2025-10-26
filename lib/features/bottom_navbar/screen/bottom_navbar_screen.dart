import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/bottom_navbar/controller/bottom_navbar_controller.dart';
import 'package:jconnect/features/home_screen/screen/home_page.dart';
import 'package:jconnect/features/my_orders/screen/my_orders_screen.dart';

class NavBarScreen extends StatelessWidget {
  const NavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavBarController controller = Get.put(NavBarController());

    final List<Widget> pages = [
      const HomePage(),
      const HomePage(),

      const MyOrdersScreen(),

      const HomePage(),
    ];

    final List<String> icons = [
      Iconpath.homeIcon,
      Iconpath.messagesIcon,
      Iconpath.orderIcon,
      Iconpath.profileIcon,
    ];

    final List<String> labels = ["Home", "Messages", "Orders", "Profile"];

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: Container(
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
