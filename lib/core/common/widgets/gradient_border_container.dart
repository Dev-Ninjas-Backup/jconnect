import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;
  final Color? color;

  const GradientBorderContainer({
    super.key,
    required this.borderRadius,
    required this.borderWidth,
    required this.gradientColors,
    required this.padding,
    required this.child,
    this.height,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.backGroundColor,
            borderRadius: BorderRadius.circular((borderRadius - borderWidth).r),
          ),
          child: child,
        ),
      ),
    );
  }
}
