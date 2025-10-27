import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomAppBar2 extends StatelessWidget {
  final String title;
  final String? actionIconUrl;
  final VoidCallback? actionOnTap;
  final String? leadingIconUrl;
  final VoidCallback? onLeadingTap;

  const CustomAppBar2({
    required this.title,
    this.actionIconUrl,
    this.actionOnTap,
    this.leadingIconUrl,
    this.onLeadingTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leadingIconUrl != null)
            GestureDetector(
              onTap: onLeadingTap,
              child: Image.asset(leadingIconUrl!, height: 36.h, width: 36.w),
            ),

          // Title
          Expanded(
            child: Center(
              child: Text(
                title,
                style: getTextStyle(
                  fontsize: sp(24),
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor,
                ),
              ),
            ),
          ),

          // Action Icon
          GestureDetector(
            onTap: actionOnTap,
            child: actionIconUrl != null
                ? Image.asset(actionIconUrl!, height: 36.h, width: 36.w)
                : SizedBox(),
          ),
        ],
      ),
    );
  }
}
