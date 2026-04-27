import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/user_profile/reviews/model/review_model.dart';

class ReviewListWidget extends StatelessWidget {
  const ReviewListWidget({super.key, required this.reviews});

  final List<ReviewModel> reviews;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];

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
                  child: Image.network(
                    review.avatarUrl,
                    width: 48.w,
                    height: 48.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        Imagepath.profileImage,
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.cover,
                      );
                    },
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
  }
}
