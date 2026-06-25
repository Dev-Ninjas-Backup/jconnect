import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/home/home_screen/widgets/spotlight_card.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../controller/home_controller.dart';

Widget repostSpotlight(HomeController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text("🔥 ", style: TextStyle(fontSize: sp(20))),
              Text(
                "\$1 Repost Spotlight",
                style: getTextStyle(
                  fontsize: sp(17),
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoute.allSpotlightScreen);
            },
            child: Text(
              "View all",
              style: getTextStyle(
                fontsize: sp(12),
                color: AppColors.secondaryTextColor,
                fontweight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),

      SizedBox(
        height: 155.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.spotlightList.length,
          itemBuilder: (context, index) {
            final item = controller.spotlightList[index];

            return SpotlightCard(item: item);
          },
        ),
      ),
    ],
  );
}
