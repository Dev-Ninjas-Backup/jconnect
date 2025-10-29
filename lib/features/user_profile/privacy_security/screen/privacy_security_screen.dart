import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: CustomAppBar2(
                title: 'Privacy & Security',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      title: 'Privacy Policy',
                      onTap: () => print('Privacy Policy tapped'),
                    ),
                    SizedBox(height: 12.h),
                    _buildSettingsTile(
                      title: 'Terms and conditions',
                      onTap: () => print('Terms tapped'),
                    ),
                    SizedBox(height: 12.h),
                    _buildSettingsTile(
                      title: 'Change password',
                      onTap: () => print('Change Password tapped'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondaryTextColor.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: getTextStyle(
                color: Colors.white,
                fontweight: FontWeight.w500,
                fontsize: 15.sp,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
