import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomAppBar2 extends StatelessWidget {
  final String title;
  final String actionIconUrl;
  final VoidCallback actionOnTap;

  const CustomAppBar2({
    required this.title,
    required this.actionIconUrl,
    required this.actionOnTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: getTextStyle(
            fontsize: sp(24),
            fontweight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        GestureDetector(
          onTap: actionOnTap,

          child: Image.asset(actionIconUrl, height: 36.h, width: 36.w),
        ),
      ],
    );
  }
}
