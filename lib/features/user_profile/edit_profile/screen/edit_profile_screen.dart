import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_appbar.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/user_profile/edit_profile/controller/edit_profile_controller.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  final EditProfileController controller = Get.put(EditProfileController());
  final ProfileController profileController = Get.find<ProfileController>();

  EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Edit Profile'),
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
                            _buildProfileImage(),
                            SizedBox(height: 25.h),
                            Text('Your First Name', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'First Name',
                              controller: controller.firstNameController,
                            ),
                            SizedBox(height: 14.h),
                            Text('Your Last Name', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Last Name',
                              controller: controller.lastNameController,
                            ),
                            SizedBox(height: 14.h),
                            Text('Bio', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Bio',
                              controller: controller.bioController,
                            ),
                            SizedBox(height: 14.h),
                            Text('About Info', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'About Info',
                              controller: controller.aboutInfoController,
                            ),
                            SizedBox(height: 14.h),
                            Text('Email', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Email',
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 14.h),
                            Text('Phone', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Phone Number',
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
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
                                    final link = controller.socialLinks[index];
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
                                              hintText: 'Username',
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
                                    : 'Save',
                                onTap: () async {
                                  if (!controller.isLoading.value) {
                                    await controller.saveProfile();
                                    await profileController.fetchProfile();
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
