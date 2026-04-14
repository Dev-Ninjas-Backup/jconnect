import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/user_profile/reviews/controller/review_controller.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReviewController>();

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondaryTextColor),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      controller.totalReviews.toString(),
                      style: getTextStyle(
                        fontsize: 16,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Total Reviews',
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontsize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 28.w),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondaryTextColor),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      '${controller.averageRating.value}/5',
                      style: getTextStyle(
                        fontsize: 16,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Average Rating',
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontsize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
