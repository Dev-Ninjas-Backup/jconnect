// ignore_for_file: deprecated_member_use

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

                            Text('Bio', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Bio',
                              controller: controller.bioController,
                            ),
                            SizedBox(height: 14.h),
                            Text('Phone', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Phone Number',
                              controller: controller.phoneController,
                              keyboardType: TextInputType.text,
                            ),

                            // extra fields
                            SizedBox(height: 14.h),
                            Text('Location', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Location',
                              controller: controller.locationController,
                            ),

                            SizedBox(height: 14.h),
                            Text('Hash Tags', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'Hash Tags',
                              controller: controller.hashTageController,
                            ),
                            SizedBox(height: 14.h),
                            Text('User Name', style: getTextStyle()),
                            SizedBox(height: 6.h),
                            CustomTextfield(
                              hintText: 'User Name',
                              controller: controller.userNameController,
                            ),

                            ///
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
                                    final selectedPlatform =
                                        link['selectedPlatform'] as String;
                                    final platformInfo =
                                        platformMap[selectedPlatform];

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Platform dropdown
                                          DropdownButtonFormField<String>(
                                            initialValue: selectedPlatform,
                                            dropdownColor:
                                                AppColors.backGroundColor,
                                            style: getTextStyle(
                                              color: AppColors.primaryTextColor,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 12.h,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: AppColors
                                                      .secondaryTextColor,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: AppColors
                                                      .primaryTextColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                            items: platformMap.keys.map((
                                              platform,
                                            ) {
                                              return DropdownMenuItem(
                                                value: platform,
                                                child: Text(
                                                  platform,
                                                  style: getTextStyle(
                                                    color: AppColors
                                                        .primaryTextColor,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                link['selectedPlatform'] =
                                                    value;
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      controller.socialLinks
                                                          .refresh();
                                                    });
                                              }
                                            },
                                          ),
                                          SizedBox(height: 8.h),
                                          // Icon + Username row
                                          Row(
                                            children: [
                                              // Platform icon with improved styling
                                              if (platformInfo != null)
                                                Container(
                                                  width: 48.w,
                                                  height: 48.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.05),
                                                    border: Border.all(
                                                      color: AppColors
                                                          .secondaryTextColor,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Image.asset(
                                                    platformInfo.iconPath,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color: AppColors
                                                              .secondaryTextColor,
                                                          size: 24,
                                                        ),
                                                  ),
                                                ),
                                              SizedBox(width: 10.w),
                                              // Username field
                                              Expanded(
                                                child: CustomTextfield(
                                                  hintText: 'Username',
                                                  controller: link['username'],
                                                ),
                                              ),
                                              // Remove button
                                              SizedBox(width: 4.w),
                                              GestureDetector(
                                                onTap: () => controller
                                                    .removeSocialLink(index),
                                                child: Container(
                                                  padding: EdgeInsets.all(8.w),
                                                  child: Icon(
                                                    Icons.remove_circle,
                                                    color: AppColors.redColor,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                            
                            // Highlights Section
                            Text(
                              'Highlights:',
                              style: getTextStyle(
                                color: Colors.white,
                                fontsize: 20,
                                fontweight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            
                            // Highlights Grid
                            Obx(
                              () => controller.highlightsPaths.isNotEmpty
                                  ? GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10.w,
                                        mainAxisSpacing: 10.h,
                                      ),
                                      itemCount: controller.highlightsPaths.length,
                                      itemBuilder: (context, index) {
                                        final path =
                                            controller.highlightsPaths[index];
                                        final isVideo = ['mp4', 'mov', 'avi', 'mkv']
                                            .contains(
                                                path.split('.').last.toLowerCase());
                                        
                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: AppColors
                                                      .secondaryTextColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: isVideo
                                                  ? Container(
                                                      color: Colors.black26,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.play_circle,
                                                          color: Colors.white,
                                                          size: 40,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.file(
                                                      File(path),
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () => controller
                                                    .removeHighlight(index),
                                                child: Container(
                                                  padding: EdgeInsets.all(2.w),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.redColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.secondaryTextColor,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No highlights added yet',
                                          style: getTextStyle(
                                            color: AppColors.secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 15.h),
                            
                            // Add Highlights Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        controller.pickHighlightImage,
                                    icon: Icon(Icons.image, color: AppColors.primaryTextColor),
                                    label: Text('Add Image',style: getTextStyle(color: AppColors.primaryTextColor),),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.redColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        controller.pickHighlightVideo,
                                    icon: Icon(Icons.videocam,color: AppColors.primaryTextColor,),
                                    label: Text('Add Video',style: getTextStyle(color: AppColors.primaryTextColor),),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.redColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              'Maximum 10 highlights allowed',
                              style: getTextStyle(
                                color: AppColors.secondaryTextColor,
                                fontsize: 12,
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
