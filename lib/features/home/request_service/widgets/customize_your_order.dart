import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';

import '../../../../core/common/constants/custom_textfield.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';
import '../controller/request_service_controller.dart';

class CustomizeYourOrder extends StatelessWidget {
  const CustomizeYourOrder({
    super.key,
    required this.controller,
  });

  final RequestServiceController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload File / Media",
          style: getTextStyle(
            fontsize: sp(12),
            fontweight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: GestureDetector(
            onTap: () {
              controller.pickImageFromGallery();
            },
            child: DottedBorder(
              options: RectDottedBorderOptions(
                color: AppColors.primaryTextColor.withValues(
                  alpha: .3,
                ),
                dashPattern: [6, 6],
                strokeWidth: .9,
                padding: EdgeInsets.all(16),
              ),
    
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
    
                  children: [
                    Image.asset(
                      Iconpath.uploadIcon,
                      height: 20.w,
                      width: 25.w,
                    ),
                    Center(
                      child: Text(
                        "Upload track, visual, or promo asset MP3, MP4, JPG, PNG up to 50MB",
    
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontsize: sp(12),
                          color: AppColors.primaryTextColor
                              .withValues(alpha: .4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    
        SizedBox(height: 24.h),
        Text(
          "Add Caption or Instructions",
          style: getTextStyle(fontsize: sp(12)),
        ),
        SizedBox(height: 12.h),
        CustomTextfield(
          hintText:
              "Write a caption or describe what you'd likethe artist to say...",
          controller: controller.captionTextController,
        ),
        SizedBox(height: 24.h),
        Text(
          "Promotion Date (Optional)",
          style: getTextStyle(fontsize: sp(12)),
        ),
        SizedBox(height: 12.h),
        GradientBorderContainer(
          borderRadius: 6.r,
          borderWidth: 0.6,
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "mm/dd/yyyy",
                  style: getTextStyle(
                    fontsize: sp(12),
                    fontweight: FontWeight.w400,
                    color: AppColors.primaryTextColor.withValues(
                      alpha: .5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.calendar_month,
                    size: sp(20),
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),        Text(
          "Promotion Date (Optional)",
          style: getTextStyle(fontsize: sp(12)),
        ),
        SizedBox(height: 12.h,),
        CustomTextfield(
          hintText: "Any extra instructions for your post?",
          controller: controller.specialNoteController,
        ),
      ],
    );
  }
}
