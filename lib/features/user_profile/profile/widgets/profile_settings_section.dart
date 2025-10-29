import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileSettingsSection extends StatelessWidget {
  final ProfileController controller;

  const ProfileSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Settings & Preferences',
              style: getTextStyle(
                color: Colors.white,
                fontweight: FontWeight.w600,
                fontsize: 18,
              ),
            ),
          ),
          Divider(color: Colors.grey, thickness: 0.15, height: 0),

          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile Details',
            onTap: () {
              Get.toNamed(AppRoute.editProfileScreen);
            },
          ),
          _buildSettingsTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Method',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.headset_mic_outlined,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            isLogout: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(
        icon,
        color: isLogout ? AppColors.redColor : AppColors.primaryTextColor,
      ),
      title: Text(
        title,
        style: getTextStyle(
          color: isLogout ? AppColors.redColor : AppColors.primaryTextColor,
          fontweight: FontWeight.w500,
          fontsize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }
}
