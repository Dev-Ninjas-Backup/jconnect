import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import '../model/repost_model.dart';

class RepostPlatformCard extends StatelessWidget {
  final RepostPlatform platform;
  final bool isSelected;
  final VoidCallback onTap;

  const RepostPlatformCard({
    super.key,
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 18,
      borderWidth: 1,

      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: platform.iconPath != null
                          ? ClipOval(
                              child: Image.asset(
                                platform.iconPath!,
                                width: 18.w,
                                height: 18.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              'X',
                              style: getTextStyle(
                                fontsize: 16,
                                fontweight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.name,
                          style: getTextStyle(
                            fontsize: 14,
                            fontweight: FontWeight.w700,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.5.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            isSelected ? 'Spotlighted' : 'Supported',
                            style: getTextStyle(
                              fontsize: 10,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: platform.repostTypes
                    .map(
                      (type) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Text(
                          type,
                          style: getTextStyle(
                            fontsize: 10,
                            fontweight: FontWeight.w500,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
