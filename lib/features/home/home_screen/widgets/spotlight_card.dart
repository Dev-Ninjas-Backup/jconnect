import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/home/home_screen/model/spotligt_model.dart';
import 'package:jconnect/features/repost/repost_start/screens/repost_screen.dart';

class SpotlightCard extends StatelessWidget {
  const SpotlightCard({
    super.key,
    required this.item,
    this.padding,
  });

  final SpotlightModel item;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(right: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(2.5.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.pink, Colors.purple],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 34.r,
                  backgroundColor: Colors.grey[900],
                  backgroundImage: AssetImage(item.avatarUrl ?? " "),
                ),
              ),
              if (item.platform != null)
                Positioned(
                  bottom: 10,
                  right: -5,
                  child: Container(
                    clipBehavior: Clip.none,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    child: Icon(item.platform, size: sp(22)),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
    
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name ?? "User",
                style: getTextStyle(
                  fontsize: sp(12),
                  fontweight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (item.isVerified == true) ...[
                SizedBox(width: 3.w),
                Icon(Icons.verified, color: Colors.red, size: sp(12)),
              ],
            ],
          ),
    
          Text(
            "${item.followers ?? '0'} Followers",
            style: getTextStyle(
              fontsize: sp(10),
              color: AppColors.secondaryTextColor,
            ),
          ),
          SizedBox(height: 6.h),
    
          GestureDetector(
          onTap: () {
             Get.to(RepostScreen());
          },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 4.h,
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
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.red.shade900, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 12.r,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "\$1 REPOST",
                    style: getTextStyle(
                      fontsize: sp(9),
                      fontweight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
