import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/splash/controller/splash_controller.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());

    const redColor = Color(0xFFBD001F);
    const whiteColor = Color(0xFFFFFFFF);
    const grayColor = Color(0xFFD5D5D5);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 160.h,
            child: Lottie.asset(
              "assets/images/icon rotate.json",
              width: 300.w,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),

          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create, Connect, Cash!",
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontsize: 18.sp,
                    fontweight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final int current = controller.progressIndex.value;

                      late final Color dotColor;
                      if (index < current) {
                        dotColor = whiteColor;
                      } else if (index == current) {
                        dotColor = redColor;
                      } else {
                        dotColor = grayColor;
                      }

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        width: 28.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: dotColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
