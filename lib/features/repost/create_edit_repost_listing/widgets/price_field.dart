import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class PriceField extends StatelessWidget {
  final TextEditingController controller;
  const PriceField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: TextField(
        controller: controller,
        style: getTextStyle(
          fontsize: 16,
          fontweight: FontWeight.w500,
          color: AppColors.primaryTextColor,
        ),
        decoration: const InputDecoration(
          prefixText: '\$ ',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
