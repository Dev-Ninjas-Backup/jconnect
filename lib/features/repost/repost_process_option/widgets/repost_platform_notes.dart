import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';

class RepostPlatformNotes extends StatelessWidget {
  const RepostPlatformNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = <String>[
      'About Reposts',
      'Share your content to a wider audience',
      'Increase your visibility',
      'Delivered fast',
    ];

    return GradientBorderContainer(
      borderRadius: 18,
      borderWidth: 1,
      gradientColors: [
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.03),
      ],
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17.r),
          color: Colors.black.withValues(alpha: 0.16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(notes.length, (index) {
            final item = notes[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == notes.length - 1 ? 0 : 8.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    index == 0
                        ? Icons.info_outline
                        : Icons.check_circle_outline,
                    color: Colors.white.withValues(alpha: 0.72),
                    size: 15.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item,
                      style: getTextStyle(
                        fontsize: index == 0 ? 12 : 11,
                        fontweight: index == 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: index == 0
                            ? AppColors.primaryTextColor
                            : AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
