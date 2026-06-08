import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../style/global_text_style.dart';
import 'gradient_border_container.dart';

class CustomBuyButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final double priceText;
  final IconData iconData;
  final Color? iConColor;

  const CustomBuyButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.priceText,
    required this.iconData,
    this.iConColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      child: GestureDetector(
        onTap: onTap,
        child: GradientBorderContainer(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
          borderRadius: 4.r,
          borderWidth: 1,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      iconData,
                      size: sp(12),
                      color:
                          iConColor ??
                          Colors.deepOrange.withValues(alpha: .910),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      buttonText,
                      style: getTextStyle(
                        fontsize: sp(9),
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 1.5.h,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF60000F),
                      Color(0xFFBB0224),
                      Color(0xFF60000F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Text(
                  "Buy",
                  style: getTextStyle(fontsize: sp(8.5), color: Colors.white),
                ),
              ),
              SizedBox(width: 4.w),

              Expanded(
                child: Text(
                  "From \$${priceText.toStringAsFixed(2)}",
                  style: getTextStyle(fontsize: sp(8.5), color: Colors.white),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          //  Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         Icon(
          //           iconData,
          //           size: sp(10),
          //           color:
          //               iConColor ?? Colors.deepOrange.withValues(alpha: .910),
          //         ),
          //         SizedBox(width: 4.w),
          //         Text(
          //           buttonText,
          //           style: getTextStyle(
          //             fontsize: sp(8.5),
          //             color: AppColors.primaryTextColor,
          //           ),
          //         ),
          //       ],
          //     ),
          //     SizedBox(width: 4.w),
          //     Container(
          //       padding: EdgeInsets.symmetric(
          //         horizontal: 2.5.w,
          //         vertical: 1.5.h,
          //       ),
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: [
          //             Color.fromARGB(255, 96, 0, 15),
          //             Color.fromARGB(255, 187, 2, 36),
          //             Color.fromARGB(255, 96, 0, 15),
          //           ],
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //           stops: [0.01, 0.5, 1.1],
          //         ),
          //         borderRadius: BorderRadius.circular(2.r),
          //       ),
          //       child: Text(
          //         "Buy",
          //         style: getTextStyle(fontsize: sp(8.5), color: Colors.white),
          //       ),
          //     ),
          //     SizedBox(width: 4.w),

          //     Flexible(
          //       child: Text(
          //         "From \$${priceText.toStringAsFixed(2)}",
          //         style: getTextStyle(fontsize: sp(8.5), color: Colors.white),
          //         overflow: TextOverflow.ellipsis,
          //         maxLines: 1,
          //         textAlign: TextAlign.right,
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
