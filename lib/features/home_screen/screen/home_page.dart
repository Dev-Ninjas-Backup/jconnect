import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home_screen/widgets/start_deal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
  HomeController controller=Get.put(HomeController());
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
          child: Column(
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

              StartDeal(controller: controller,),
            ],
          ),
        ),
      ),
    );
  }
}
