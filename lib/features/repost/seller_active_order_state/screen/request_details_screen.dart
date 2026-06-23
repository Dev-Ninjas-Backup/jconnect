import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/seller_active_order_state/controller/request_details_controller.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RepostStatusItem item;
  const RequestDetailsScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestDetailsController(item: item));

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "Request Details",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),

              SizedBox(height: 30.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      controller.platformIconPath,
                      height: 28.h,
                      width: 28.w,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 28.r,
                        );
                      },
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repost Option',
                          style: getTextStyle(
                            fontsize: 12,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          controller.optionText,
                          style: getTextStyle(
                            fontsize: 13,
                            fontweight: FontWeight.w600,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ─── Time to Complete Section ─────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Time to Complete',
                      style: getTextStyle(
                        fontsize: 12,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Obx(() {
                      return Text(
                        controller.formattedTime,
                        style: getTextStyle(
                          fontsize: 36,
                          fontweight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      );
                    }),
                    SizedBox(height: 6.h),
                    Text(
                      'Time remaining',
                      style: getTextStyle(
                        fontsize: 11,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment',
                      style: getTextStyle(
                        fontsize: 12,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '\$${item.amount.toStringAsFixed(2)}',
                      style: getTextStyle(
                        fontsize: 24,
                        fontweight: FontWeight.w700,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Secure escrow until you approve the repost',
                      style: getTextStyle(
                        fontsize: 11,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ─── Action Buttons ───────────────────────────────────────
              CustomPrimaryButton(
                buttonText: 'Accept Request',
                onTap: () => controller.acceptRequest(),
              ),

              SizedBox(height: 12.h),

              OutlinedButton(
                onPressed: () => controller.rejectRequest(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Reject Request',
                  style: getTextStyle(
                    fontsize: 16,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
