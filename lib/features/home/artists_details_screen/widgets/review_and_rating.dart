import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../controller/artists_details_controller.dart';

class ReviewAndRating extends StatelessWidget {
  const ReviewAndRating({super.key, required this.controller});

  final ArtistsDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final reviews =
        controller.artistsDetails.value?.reviewsReceived ?? [];

    if (reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            'No reviews yet',
            style: getTextStyle(
              fontsize: 13,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reviews.length,
      itemBuilder: (_, index) {
        var item = reviews[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.backGroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reviewer avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  item.reviewer?.profilePhoto ?? "",
                  height: 40.w,
                  width: 40.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 40.w,
                    width: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade800,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 22.sp,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Review content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username + rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.reviewer?.username ?? 'Unknown',
                          style: getTextStyle(
                            fontsize: 14,
                            fontweight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.redColor,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              (item.rating ?? 0).toString(),
                              style: getTextStyle(
                                fontsize: 13,
                                fontweight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Review text
                    Text(
                      item.reviewText ?? "No review text",
                      style: getTextStyle(
                        fontsize: 12,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
