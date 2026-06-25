import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const DropdownField({super.key, 
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
          style: getTextStyle(
            fontsize: 16,
            fontweight: FontWeight.w500,
            color: AppColors.primaryTextColor,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    e.toString(),
                    style: getTextStyle(
                      fontsize: 16,
                      fontweight: FontWeight.w500,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
