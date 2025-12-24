import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/payment/payment_screen.dart';
import 'package:jconnect/routes/approute.dart';

class AddStripe extends StatelessWidget {
  const AddStripe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Payment Method',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              Spacer(),
              Text(
                'Connect Your Stripe Account',
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 18,
                  fontweight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Secure payouts are processed through Stripe. Connect your account to start receiving payments.',
                style: getTextStyle(
                  fontsize: 13,
                  color: AppColors.secondaryTextColor,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 18.h),
              CustomPrimaryButton(
                buttonText: 'Connect With Stripe',
                onTap: () {
                Get.to(PaymentPage());
                //  Get.toNamed(AppRoute.manageViaStripe);
                },
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
