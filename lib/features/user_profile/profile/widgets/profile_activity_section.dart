import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/screen/messages_screen.dart';
import 'package:jconnect/features/my_orders/screen/my_orders_screen.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
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
        'icon': Icons.star_border_rounded,
        'label': 'Reviews',
        'onTap': () => {Get.toNamed(AppRoute.reviewScreen)},
      },
      {
        'icon': Icons.build_circle_outlined,
        'label': 'My Services',
        'onTap': () {
          Get.toNamed(AppRoute.addServiceScreen);
        },
      },
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      padding: EdgeInsets.all(16),
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
          SizedBox(height: 12),
          ...items.map(
            (item) => _buildActivityItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              onTap: item['onTap'] as VoidCallback,
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.secondaryTextColor, width: 0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryTextColor, size: 22),
            SizedBox(width: 12),
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
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
