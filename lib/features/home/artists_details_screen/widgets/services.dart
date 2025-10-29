import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';
import '../controller/artists_details_controller.dart';

class Services extends StatelessWidget {
  const Services({
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
      itemCount: controller.serviceListItem.length,
      itemBuilder: (_, index) {
        var item = controller.serviceListItem[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: GradientBorderContainer(
            borderRadius: 6.r,
            borderWidth: .5,
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 12.w),
                Text(
                  item.title,
                  style: getTextStyle(
                    fontsize: sp(16),
                    fontweight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
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
                SizedBox(height: 8.h),
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
                      buttonWidth: 109.w,
    
                      buttonText: "Request Service",
                      fontSize: sp(10),
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
