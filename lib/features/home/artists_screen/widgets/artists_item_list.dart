import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import '../../../../core/common/constants/app_colors.dart';
class ArtistsItemList extends StatelessWidget {
  const ArtistsItemList({
    super.key,
    required this.controller,
  });

  final ArtistsController controller;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(controller.artistItem.length, (
          index,
        ) {
          final bool isSelect =
              controller.selectArtistsItemIndex.value == index;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                controller.selectArtistsItemIndex.value = index;
              },
              child: GradientBorderContainer(
                borderRadius: 6.r,
                borderWidth: 0.5,
                gradientColors: [
                  AppColors.primaryTextColor,
                  AppColors.primaryTextColor.withValues(alpha: .5),
                ],
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 8.h,
                ),
                color: isSelect
                    ? AppColors.redColor
                    : AppColors.backGroundColor,
                child: Text(
                  controller.artistItem[index],
                  style: getTextStyle(
                    fontsize: sp(12),
                    fontweight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}