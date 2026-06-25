import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final int currentLength;
  final int maxLength;

  const DescriptionField({
    super.key,
    required this.controller,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller,
            maxLines: 5,
            maxLength: maxLength,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
            style: getTextStyle(
              fontsize: 15,
              fontweight: FontWeight.w400,
              color: AppColors.primaryTextColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'What buyers can expect...',
              hintStyle: getTextStyle(
                fontsize: 15,
                fontweight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$currentLength/$maxLength',
            style: getTextStyle(
              fontsize: 12,
              fontweight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
