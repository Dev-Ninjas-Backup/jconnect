import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';
import '../controller/artists_details_controller.dart';

class ReviewAndRating extends StatelessWidget {
  const ReviewAndRating({
    super.key,
    required this.controller,
  });

  final ArtistsDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: controller.reviewAndRatingListItem.length,
          itemBuilder: (_, index) {
            var item = controller.reviewAndRatingListItem[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: GradientBorderContainer(
                borderRadius: 9.r,
                borderWidth: .75,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                child: Row(
                  spacing: 8.w,
                  children: [
                    Image.asset(
                      item.imageUrl,
                      height: 40.w,
                      width: 40.w,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          //sonic+ rating
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.title,
                                style: getTextStyle(
                                  fontweight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppColors.primaryTextColor,
                                    size: sp(14),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    item.rating.toString(),
                                    style: getTextStyle(
                                      fontsize: sp(12),
                                      fontweight: FontWeight.w500,
                                      color: AppColors
                                          .primaryTextColor
                                          .withValues(alpha: .70),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            item.subTitle,
                            style: getTextStyle(
                              fontsize: sp(10),
                              color: AppColors.primaryTextColor
                                  .withValues(alpha: .5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "View more",
            style: getTextStyle(
              fontsize: sp(12),
              fontweight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
