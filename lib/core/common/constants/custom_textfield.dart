import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomTextfield extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final Function(String)? onChanged;
  final Widget ?prefixIcon;


  const CustomTextfield({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onChanged,
    this.prefixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h,horizontal: 1.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),

        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style:  TextStyle(color: Colors.white),
          decoration: InputDecoration(
         prefixIcon: prefixIcon,
            contentPadding:  EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,

            ),
            filled: true,
            fillColor: Colors.transparent,
            hintText: hintText,
            hintStyle: getTextStyle(color: AppColors.secondaryTextColor),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
