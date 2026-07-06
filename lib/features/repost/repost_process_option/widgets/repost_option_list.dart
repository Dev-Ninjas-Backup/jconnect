import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import 'package:jconnect/features/repost/repost_process_option/controller/repost_process_option_controller.dart';
import 'package:jconnect/features/repost/repost_process_option/screens/repost_comtent_payment_screen.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';

class RepostOptionList extends StatelessWidget {
  final RepostPlatform platform;

  const RepostOptionList({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RepostProcessOptionController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available repost options',
          style: getTextStyle(
            fontsize: 15,
            fontweight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
        ),
        SizedBox(height: 10.h),
        ...platform.repostOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: GestureDetector(
              onTap: () => controller.selectOption(index),
              child: GradientBorderContainer(
                borderRadius: 18,
                borderWidth: 1,
                padding: EdgeInsets.zero,

                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: getTextStyle(
                                fontsize: 14,
                                fontweight: FontWeight.w700,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              option.price,
                              style: getTextStyle(
                                fontsize: 14,
                                fontweight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          controller.selectOption(index);
                          Get.to(
                            RepostContentPaymentScreen(
                              listingId: option.listingId,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF60000F),
                                Color(0xFFBB0224),
                                Color(0xFF60000F),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            'Select',
                            style: getTextStyle(
                              fontsize: 11,
                              fontweight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
