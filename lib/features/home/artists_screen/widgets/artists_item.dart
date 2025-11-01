import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

class ArtistsItem extends StatelessWidget {
  final ArtistsController controller;
  const ArtistsItem({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: controller.artistsItems.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 15,
          childAspectRatio: .4,
        ),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (_, index) {
          final item = controller.artistsItems[index];
          return GradientBorderContainer(
            borderRadius: 10.r,
            borderWidth: 1,
            gradientColors: [Colors.white, Colors.white.withValues(alpha: .5)],
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    //  borderRadius: BorderRadiusGeometry.circular(100.r),
                    child: Image.asset(
                      item.imageUrl,
                      height: 60.h,
                      width: 60.w,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoute.artistsDetailsPage);
                      },
                      child: Text(
                        item.name,
                        style: getTextStyle(
                          fontsize: sp(13.5),
                          fontweight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          width: .25,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      child: Text(
                        "From \$${item.ammount}",
                        style: getTextStyle(
                          fontsize: sp(8),
                          color: AppColors.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                Text(
                  item.heading,
                  style: getTextStyle(
                    fontsize: sp(10),
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Services:",
                  style: getTextStyle(
                    fontsize: sp(10),
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  item.services,
                  style: getTextStyle(
                    fontsize: sp(10),
                    color: AppColors.secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 10.h),
                Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RatingBarIndicator(
                      rating: item.rating.toDouble(),
                      itemBuilder: (context, index) =>
                          Icon(Icons.star, color: Color(0xffBD001F)),
                      itemCount: 5,
                      itemSize: sp(12),
                      direction: Axis.horizontal,
                      unratedColor: Color(0xFFD96B7D),
                    ),
                    Text(
                      "${item.rating} (${item.reviews} Reviews)",
                      style: getTextStyle(
                        fontsize: sp(10),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Spacer(),
                CustomPrimaryButton(buttonText: "Message", onTap: () {}),
                SizedBox(height: 14.h),
                CustomSecondaryButton(buttonText: "Custom Order", onTap: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}
