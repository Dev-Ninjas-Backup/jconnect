import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/repost_process_option/controller/repost_process_option_controller.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/screen/my_orders_screen.dart';

class SetCompletionTimeScreen extends StatelessWidget {
  final String listingId;
  final String paymentUrl;
  final String paymentIntentId;
  final int amount;
  final String currency;

  const SetCompletionTimeScreen({
    super.key,
    required this.listingId,
    required this.paymentUrl,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RepostProcessOptionController>();
    final selectedOption = controller.currentPlatform.repostOptions[controller.selectedOptionIndex.value];

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: CustomAppBar2(
                title: 'Set Completion Time',
                onLeadingTap: () => Get.back(),
                leadingIconUrl: Iconpath.backIcon,
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    Text(
                      'Choose how much time the seller has to repost your content.',
                      style: getTextStyle(
                        fontsize: 13,
                        fontweight: FontWeight.w400,
                        color: AppColors.primaryTextColor,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      'Countdown starts when you submit this request.',
                      style: getTextStyle(
                        fontsize: 13,
                        fontweight: FontWeight.w400,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'Select Timeframe',
                      style: getTextStyle(
                        fontsize: 16,
                        fontweight: FontWeight.w500,
                        color: AppColors.primaryTextColor,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Obx(() {
                      return Column(
                        children: List.generate(
                          controller.timeframes.length,
                          (index) => _TimeframeOption(
                            label: controller.timeframes[index],
                            isSelected: controller.selectedIndex.value == index,
                            onTap: () => controller.selectTimeframe(index),
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: getTextStyle(
                              fontsize: 14,
                              fontweight: FontWeight.w500,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          Text(
                            selectedOption.price,
                            style: getTextStyle(
                              fontsize: 14,
                              fontweight: FontWeight.w700,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    CustomPrimaryButton(
                      buttonText: 'Continue',
                      onTap: () async {
                        final success = await controller.createRepostOrder(
                          listingId: listingId,
                          contentUrl: paymentUrl,
                          paymentIntentId: paymentIntentId,
                          timeframe: controller.selectedTimeframeEnum,
                        );
                        if (success) {
                          final ordersController = Get.put(MyOrdersController());
                          ordersController.selectedMainTab.value = OrderMainTab.repostService;
                          Get.offAll(() => const MyOrdersScreen());
                        }
                      },
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeframeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeframeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            // Custom radio circle
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.redColor
                      : Colors.white.withValues(alpha: 0.4),
                  width: isSelected ? 0 : 1.5,
                ),
                color: isSelected ? AppColors.redColor : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(width: 12.w),

            Text(
              label,
              style: getTextStyle(
                fontsize: 14,
                fontweight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryTextColor
                    : AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
