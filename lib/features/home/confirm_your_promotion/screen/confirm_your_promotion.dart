import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';

import '../widgets/confirm_promotion_upper_card.dart';

class ConfirmYourPromotion extends StatelessWidget {
  const ConfirmYourPromotion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: Column(
          children: [
            CustomAppBar2(
              title: "Confirm Promotion",
              leadingIconUrl: Iconpath.backIcon,
              onLeadingTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 40.h),
            ConfirmPromotionUpperCard(),
          ],
        ),
      ),
    );
  }
}

