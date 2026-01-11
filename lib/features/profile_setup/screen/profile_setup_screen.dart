import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/features/profile_setup/controller/profile_setup_controller.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileSetupScreen extends StatelessWidget {
  final SetUpProfileController controller = Get.put(SetUpProfileController());
  final ProfileController profileController = Get.put(ProfileController());

  ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.redColor,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                          vertical: 20.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Let's build your profile",
                                    style: getTextStyle(
                                      fontsize: 22,
                                      fontweight: FontWeight.w600,
                                      color: AppColors.primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Share who you are and what you do, this helps others connect with you faster.',
                                    textAlign: TextAlign.center,
                                    style: getTextStyle(
                                      fontsize: 14,
                                      fontweight: FontWeight.w500,
                                      color: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16,),
        
                            Text(
                              'Upload Profile Image',
                              style: getTextStyle(
                                fontsize: 16,
                                fontweight: FontWeight.w500,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildProfileImage(),
        
                            SizedBox(height: 14.h),
                            Text('Add Short Bio', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Enter Your Short Bio',
                              controller: controller.bioController,
                            ),
        
                            const SizedBox(height: 8),
                            Text(
                              'Tip: Keep it short, describe your role and what makes your style unique.',
                              style: getTextStyle(
                                fontsize: 12,
                                fontweight: FontWeight.w400,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
        
                            SizedBox(height: 25.h),
                            Text(
                              'Social Links:',
                              style: getTextStyle(
                                color: Colors.white,
                                fontsize: 20,
                                fontweight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Obx(
                              () => Column(
                                children: List.generate(
                                  controller.socialLinks.length,
                                  (index) {
                                    final link =
                                        controller.socialLinks[index];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextfield(
                                              hintText: 'Platform',
                                              controller: link['platform'],
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            flex: 2,
                                            child: CustomTextfield(
                                              hintText: 'Profile Link',
                                              controller: link['username'],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => controller
                                                .removeSocialLink(index),
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color: AppColors.redColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            GestureDetector(
                              onTap: controller.addSocialLink,
                              child: Text(
                                '+ Add more social links',
                                style: getTextStyle(
                                  color: AppColors.redAccent,
                                  fontweight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Obx(
                              () => CustomPrimaryButton(
                                buttonText: controller.isLoading.value
                                    ? 'Saving...'
                                    : 'Next',
                                onTap: () async {
                                  if (!controller.isLoading.value) {
                                    controller.saveProfile();
                                    showProfileSuccessPopup(context);
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Obx(() {
      return Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: controller.pickImage,
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: controller.imagePath.value.isNotEmpty
                    ? FileImage(File(controller.imagePath.value))
                    : profileController.user.value.imageUrl.startsWith('http')
                    ? NetworkImage(profileController.user.value.imageUrl)
                    : AssetImage(profileController.user.value.imageUrl),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                controller.pickImage();
              },
              child: Text('Change Photo', style: getTextStyle()),
            ),
          ],
        ),
      );
    });
  }
}

void showProfileSuccessPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backGroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              "You’re all set!",
              style: getTextStyle(
                fontsize: 22,
                fontweight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your profile is live. You can now explore top artists, and creators, or start offering your own services.",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: 14,
                fontweight: FontWeight.w500,
                color: AppColors.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 28),
            CustomPrimaryButton(
              buttonText: 'Browse Feed',
              onTap: () {
                Get.back();
                Get.offAllNamed(AppRoute.navBarScreen);
              },
            ),
            const SizedBox(height: 12),
            CustomSecondaryButton(
              buttonText: 'Add Your Services',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoute.addServiceScreen);
              },
            ),
            const SizedBox(height: 16),
            Text(
              "You can always edit your profile or add more services later from your Profile tab.",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: 12,
                fontweight: FontWeight.w400,
                color: AppColors.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
