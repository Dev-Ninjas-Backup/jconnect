import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/controller/earnings_controller.dart';

class EarningsSection extends StatelessWidget {
  const EarningsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<EarningsController>(
      init: EarningsController(),
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backGroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondaryTextColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Earnings',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 16.sp,
                    ),
                  ),
                  Text(
                    '\$${controller.totalEarnings}',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 16.sp,
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.secondaryTextColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Clearance',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 16.sp,
                    ),
                  ),
                  Text(
                    '\$${controller.pendingClearance}',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 16.sp,
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.secondaryTextColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available to Withdraw',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 16.sp,
                    ),
                  ),
                  Text(
                    '\$${controller.availableToWithdraw}',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomPrimaryButton(buttonText: 'Withdraw', onTap: () {}),
            ],
          ),
        );
      },
    );
  }
}
