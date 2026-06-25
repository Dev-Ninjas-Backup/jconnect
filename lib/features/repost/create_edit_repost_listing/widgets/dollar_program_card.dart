import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class DollarProgramCard extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const DollarProgramCard({super.key, required this.isEnabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accepts \$1 Repost Program',
                  style: getTextStyle(
                    fontsize: 15,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Get featured in the \$1 Repost\nSpotlight on homepage',
                  style: getTextStyle(
                    fontsize: 12,
                    fontweight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.redColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF3A3A3A),
          ),
        ],
      ),
    );
  }
}
