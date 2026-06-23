import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_activity_section.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_header.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_listings_section.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_settings_section.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final SharedPreferencesHelperController pref = Get.put(
    SharedPreferencesHelperController(),
  );

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileHeader(controller: controller),
                SizedBox(height: 20.h),
                ProfileActivitySection(controller: controller),
                SizedBox(height: 16.h),
                ProfileListingsSection(controller: controller),
                SizedBox(height: 16.h),
                ProfileSettingsSection(controller: controller),
                SizedBox(height: 18.h),
                GestureDetector(
                  onTap: () async {
                    await controller.deleteAccountAsync();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_forever,
                        size: 24,
                        color: AppColors.redColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: getTextStyle(
                          fontsize: 16,
                          color: AppColors.redColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
