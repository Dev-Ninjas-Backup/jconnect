import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';

import '../widgets/confirm_promotion_dialog.dart';
import '../widgets/confirm_promotion_upper_card.dart';
import '../widgets/payment_breakdown.dart';

class ConfirmYourPromotion extends StatelessWidget {
  const ConfirmYourPromotion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 40.h),
              Text(
                "Payment Breakdown",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor.withValues(alpha: .7),
                ),
              ),
              SizedBox(height: 16),

              PaymentBreakDown(),
              SizedBox(height: 60.h),
              CustomPrimaryButton(
                buttonText: "Confirm & Pay \$82.50",
                onTap: () {
                  showDeleteDialog();
                },
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "Need something custom? → Create Custom Request",
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontsize: sp(10),
                    color: AppColors.primaryTextColor.withValues(alpha: .4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
