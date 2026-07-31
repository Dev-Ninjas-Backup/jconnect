import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class OrderSectionHeader extends StatelessWidget {
  final String title;
  final String subtitleSuffix;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color badgeBgColor;
  final Color badgeBorderColor;

  const OrderSectionHeader({
    super.key,
    required this.title,
    required this.subtitleSuffix,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.badgeBgColor,
    required this.badgeBorderColor,
  });

  factory OrderSectionHeader.received() {
    return const OrderSectionHeader(
      title: 'Orders Received',
      subtitleSuffix: '(You will deliver)',
      description: 'Blue orders are from creators who purchased from you.',
      icon: Icons.move_to_inbox_rounded,
      iconColor: Color(0xFF3B82F6),
      badgeBgColor: Color(0xFF0F172A),
      badgeBorderColor: Color(0xFF1E293B),
    );
  }

  factory OrderSectionHeader.purchased() {
    return const OrderSectionHeader(
      title: 'Orders Purchased',
      subtitleSuffix: '(You bought)',
      description: 'Green orders are services you purchased.',
      icon: Icons.move_to_inbox_rounded,
      iconColor: Color(0xFF22C55E),
      badgeBgColor: Color(0xFF09160F),
      badgeBorderColor: Color(0xFF143823),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 8.h, left: 4.w, right: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: badgeBorderColor),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: getTextStyle(
                          color: AppColors.primaryTextColor,
                          fontweight: FontWeight.bold,
                          fontsize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' $subtitleSuffix',
                        style: getTextStyle(
                          color: const Color(0xFF94A3B8),
                          fontweight: FontWeight.w400,
                          fontsize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: getTextStyle(
                    color: const Color(0xFF64748B),
                    fontweight: FontWeight.w400,
                    fontsize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
