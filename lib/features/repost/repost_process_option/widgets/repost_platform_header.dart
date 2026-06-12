import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';

class RepostPlatformHeader extends StatelessWidget {
  final RepostPlatform platform;

  const RepostPlatformHeader({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: Center(
              child: platform.iconPath != null
                  ? ClipOval(
                      child: Image.asset(
                        platform.iconPath!,
                        width: 22.w,
                        height: 22.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      'X',
                      style: getTextStyle(
                        fontsize: 20,
                        fontweight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform.heroTitle,
                  style: getTextStyle(
                    fontsize: 18,
                    fontweight: FontWeight.w700,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  platform.heroSubtitle,
                  style: getTextStyle(
                    fontsize: 12,
                    fontweight: FontWeight.w400,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
