import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry padding;
  final double ?height;
  final double ?width;

  const GradientBorderContainer({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.borderWidth,
    required this.gradientColors,
    required this.padding,
    this.height,
    this.width
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
            color: Colors.black,
            borderRadius: BorderRadius.circular((borderRadius - 1).r),
          ),
          child: child,
        ),
      ),
    );
  }
}
