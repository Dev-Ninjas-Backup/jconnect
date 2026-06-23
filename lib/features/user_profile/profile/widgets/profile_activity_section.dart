import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/screen/messages_screen.dart';
import 'package:jconnect/features/my_orders/screen/my_orders_screen.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/repost/repost_status/screen/repost_status.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileActivitySection extends StatelessWidget {
  final ProfileController controller;

  const ProfileActivitySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'My Orders',
        'onTap': () {
          Get.to(MyOrdersScreen());
        },
      },
      {
        'icon': Icons.attach_money_rounded,
        'label': 'Earnings & Payouts',
        'onTap': () {
          Get.toNamed(AppRoute.earningsAndPayouts);
        },
      },
      {
        'icon': Icons.mail_outline,
        'label': 'Messages',
        'onTap': () => {Get.to(MessagesScreen())},
      },
      {
        'icon': Icons.people_outline_rounded,
        'label': 'Followers & Followings',
        'onTap': () => Get.toNamed(AppRoute.followScreen),
      },
      {
        'icon': Icons.star_border_rounded,
        'label': 'Reviews',
        'onTap': () => {Get.toNamed(AppRoute.reviewScreen)},
      },
      {
        'icon': Icons.repeat,
        'label': 'Reposts Status',
        'onTap': () {

          Get.to(RepostStatuScreen());

        },
      },
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Activity',
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontweight: FontWeight.bold,
              fontsize: 16,
            ),
          ),
          SizedBox(height: 8.h),
          ...items.map(
            (item) => _buildActivityItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              onTap: item['onTap'] as VoidCallback,
              isLast: item == items.last,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTextColor, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                  fontweight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.secondaryTextColor,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
