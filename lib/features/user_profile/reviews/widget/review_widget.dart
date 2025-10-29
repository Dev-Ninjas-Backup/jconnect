import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 100.h,
    
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondaryTextColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    '32 Reviews',
                    style: getTextStyle(
                      fontsize: 20,
                      fontweight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Total Reviews',
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontsize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 28.w),
        Expanded(
          child: Container(
            height: 100.h,
    
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondaryTextColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    '4.9/5',
                    style: getTextStyle(
                      fontsize: 20,
                      fontweight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Avarage Rating',
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontsize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
