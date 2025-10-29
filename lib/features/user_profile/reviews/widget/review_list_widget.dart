import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/user_profile/reviews/controller/review_controller.dart';

class ReviewListWidget extends StatelessWidget {
  const ReviewListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ReviewController>(
      init: ReviewController(),
      builder: (controller) {
        return ListView.builder(
          itemCount: controller.reviews.length,
          itemBuilder: (context, index) {
            var review = controller.reviews[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backGroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondaryTextColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        review.avatarUrl,
                        height: 50.h,
                        width: 50.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                review.username,
                                style: getTextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontsize: 16.sp,
                                  fontweight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    review.rating.toString(),
                                    style: getTextStyle(
                                      color: AppColors.primaryTextColor,
                                      fontsize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            review.description,
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
