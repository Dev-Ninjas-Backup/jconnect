import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';
import '../controller/artists_details_controller.dart';

class SocialPost extends StatelessWidget {
  const SocialPost({
    super.key,
    required this.controller,
  });

  final ArtistsDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.socialPostListItem.length,
      itemBuilder: (_, index) {
      var item=controller.socialPostListItem[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: GradientBorderContainer(
            borderRadius: 8.r,
            borderWidth: .75,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                     item.iconUrl,
                      height: 22,
                      width: 22,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                     item.title,
                      style: getTextStyle(
                        fontsize: sp(16),
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                 item.subTitle,
                  style: getTextStyle(
                    fontsize: sp(10),
                    fontweight: FontWeight.w400,
                    color: AppColors.primaryTextColor.withValues(
                      alpha: .5,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
    
                  children: [
                    Expanded(
                      child: Text(
                        "${item.rate}/promotion",
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w400,
                          color: AppColors.primaryTextColor
                              .withValues(alpha: .7),
                        ),
                      ),
                    ),
                    CustomPrimaryButton(
                      buttonHeight: 10.h,
                      buttonWidth: 75.w,
    
                      buttonText: "Buy Post",
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}