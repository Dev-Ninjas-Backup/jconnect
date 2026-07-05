import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileListingsSection extends StatelessWidget {
  final ProfileController controller;

  const ProfileListingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      padding: EdgeInsets.all(16.w),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with "My Listings" and "View All"
            Text(
              'My Listings',
              style: getTextStyle(
                color: AppColors.primaryTextColor,
                fontweight: FontWeight.bold,
                fontsize: 16,
              ),
            ),
            SizedBox(height: 12.h),

            // Services item
            _buildListingItem(
              icon: Icons.design_services_rounded,
              iconBgColor: const Color(0xFF2D1A1A),
              iconColor: AppColors.redColor,
              label: 'Services',
              count: controller.user.value.service.toString(),
              onTap: () {
                Get.toNamed(
                  AppRoute.addServiceScreen,
                  arguments: {'serviceType': 'SERVICE'},
                );
              },
            ),

            // Social Posts item
            _buildListingItem(
              icon: Icons.grid_view_rounded,
              iconBgColor: const Color(0xFF1A2D1A),
              iconColor: const Color(0xFF4CAF50),
              label: 'Social Posts',
              count: controller.user.value.socialPost.toString(),
              onTap: () {
                Get.toNamed(
                  AppRoute.addServiceScreen,
                  arguments: {'serviceType': 'SOCIAL_POST'},
                );
              },
            ),

            // Reposts item
            _buildListingItem(
              icon: Icons.repeat_rounded,
              iconBgColor: const Color(0xFF2D1A2A),
              iconColor: const Color(0xFFE91E63),
              label: 'Reposts',
              count: controller.user.value.repost.toString(),
              isLast: true,
              onTap: () {
                Get.toNamed(AppRoute.repostListingsScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String count,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
                ),
        ),
        child: Row(
          children: [
            // Colored circle icon
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
            ),
            SizedBox(width: 12.w),
            // Label
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
            // Count badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Text(
                count,
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 12,
                  fontweight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Chevron
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
