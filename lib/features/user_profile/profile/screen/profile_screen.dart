import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_activity_section.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_rate_section.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_settings_section.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
    final SharedPreferencesHelperController pref =
      Get.put(SharedPreferencesHelperController());

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoute.editProfileScreen);
                },
                child: Text(
                  'Edit Profile',
                  selectionColor: AppColors.redAccent,
                ),
              ),
              SizedBox(height: 20),
              ProfileRateSection(controller: controller),
              SizedBox(height: 20),
              ProfileActivitySection(controller: controller),
              SizedBox(height: 20),
              ProfileSettingsSection(controller: controller),
              SizedBox(height: 18.h),
              GestureDetector(

              onTap: () async{
             await pref.clearAllData();
                Get.toNamed(AppRoute.loginScreen);
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage(Imagepath.profileImage),
          ),
          SizedBox(height: 10),
          Text(
            user.name,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 20,
              fontweight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('${user.followers}', 'Followers'),
              _divider(),
              _buildStat('\$${user.earnings}', 'Earnings'),
              _divider(),
              _buildStat('${user.rating}', 'Rating'),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStat(String value, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            value,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 16,
              fontweight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 20, width: 1, color: Colors.grey.shade700);
}
