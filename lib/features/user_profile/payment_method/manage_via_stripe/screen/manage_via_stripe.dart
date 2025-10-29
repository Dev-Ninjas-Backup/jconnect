import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/user_profile/payment_method/manage_via_stripe/controller/manage_viaStripe_controller.dart';

class ManageViaStripe extends StatelessWidget {
  const ManageViaStripe({super.key});

  @override
  Widget build(BuildContext context) {
    final StripeController stripeController = Get.put(StripeController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Custom AppBar
              CustomAppBar2(
                title: 'Payment Method',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 22.h),

              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondaryTextColor),
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0XFF353434),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        stripeController.profileImage.value,
                        height: 50.h,
                        width: 50.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.h),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DJ Wave',
                            style: TextStyle(
                              color: AppColors.primaryTextColor,
                              fontSize: 18.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          Text(
                            'djwave.music@email.com',
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 14,
                            ),
                          ),
                          SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 12),
                              SizedBox(width: 8),
                              Text(
                                stripeController.stripeStatus.value,
                                style: getTextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontsize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Row(
                children: [
                  Text(
                    'Last Payout:',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    stripeController.lastPayout.value,
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Account Status:',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    stripeController.accountStatus.value,
                    style: getTextStyle(
                      color: stripeController.accountStatus.value == 'Verified'
                          ? Colors.green
                          : Colors.orange,
                      fontsize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              CustomPrimaryButton(
                buttonText: 'Manage Via Stripe',
                onTap: () {},
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: AppColors.secondaryTextColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All payments are securely handled via Stripe’s encrypted system. DJ Connect takes a 10% platform fee per completed transaction.',
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontsize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
