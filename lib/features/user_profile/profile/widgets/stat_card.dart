import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.backGroundColor,
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at top
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.redColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.redColor, size: 18.sp),
            ),
          ),
          SizedBox(height: 8.h),
          // Value
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 16,
              fontweight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          // Label
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
