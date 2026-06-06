import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button_2.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';
import 'package:jconnect/features/add_services/widget/service_form_widget.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_activity_section.dart';
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
                _buildHeader(),
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

  Widget _buildHeader() {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          SizedBox(height: 10.h),
          // Profile image with white circle background
          Container(
            width: 100.w,
            height: 100.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: CircleAvatar(
                radius: 47.w,
                backgroundImage: user.imageUrl.startsWith('http')
                    ? NetworkImage(user.imageUrl) as ImageProvider
                    : AssetImage(user.imageUrl) as ImageProvider,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Username
          Text(
            user.username,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 20,
              fontweight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          // Short bio
          Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            user.shortbio,
            textAlign: TextAlign.center,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 14,
            ),
          ),
          SizedBox(height: 20.h),

          // Three sell buttons row
          Row(
            children: [
              Expanded(
                child: CustomPrimaryButton2(
                  buttonText: "Sell Social Post",
                  fontSize: sp(11),
                  buttonHeight: 40,
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    _showAddServiceSheet(addServiceController);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomPrimaryButton2(
                  buttonText: "Sell Repost",
                  fontSize: sp(11),
                  buttonHeight: 40,
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    _showAddServiceSheet(addServiceController);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomPrimaryButton2(
                  buttonText: "Sell Services",
                  fontSize: sp(11),
                  buttonHeight: 40,
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    _showAddServiceSheet(addServiceController);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Stats row with icons
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.shopping_bag_outlined,
                  value: '${user.totaldeals}',
                  label: 'Total Deals',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money_rounded,
                  value: '\$${user.earnings.toStringAsFixed(2)}',
                  label: 'Earnings',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star_border_rounded,
                  value: user.rating.toStringAsFixed(1),
                  label: 'Rating',
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.backGroundColor,
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at top
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.redColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.redColor, size: 18.sp),
            ),
          ),
          SizedBox(height: 8.h),
          // Value
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 16,
              fontweight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          // Label
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddServiceSheet(AddServiceController controller) {
  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ServiceFormWidget(controller),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.saveService();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
