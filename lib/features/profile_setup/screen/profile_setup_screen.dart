// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/features/profile_setup/controller/profile_setup_controller.dart';
import 'package:jconnect/features/profile_setup/widget/profile_image.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ProfileSetupController controller = Get.put(ProfileSetupController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- HEADER ---
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

              const SizedBox(height: 32),

              Text(
                'Upload Profile Image',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 18),

              ProfileImage(controller: controller, size: size),

              const SizedBox(height: 32),

              Text(
                'Add Short Bio',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              CustomTextfield(
                hintText:
                    'DJ + Producer • Passionate about mixing beats and connecting vibes.',
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

              const SizedBox(height: 32),

              Text(
                'Link your socials',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),

              /// --- DYNAMIC SOCIAL MEDIA SECTION ---
              Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.socialInputs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.socialInputs[index];
                      return Row(
                        children: [
                          // --- PLATFORM DROPDOWN ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: item.selectedPlatform,
                                hint: Text(
                                  "Platform",
                                  style: getTextStyle(
                                      fontsize: 12, color: AppColors.secondaryTextColor),
                                ),
                                dropdownColor: AppColors.backGroundColor,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                items: controller.availablePlatforms.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: getTextStyle(fontsize: 14, color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  item.selectedPlatform = newValue;
                                  controller.socialInputs.refresh();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // --- URL INPUT ---
                          Expanded(
                            child: CustomTextfield(
                              hintText: 'Profile URL / Username',
                              controller: item.urlController,
                            ),
                          ),

                          // --- REMOVE BUTTON ---
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => controller.removeSocialField(index),
                          ),
                        ],
                      );
                    },
                  )),

              const SizedBox(height: 12),

              // --- ADD BUTTON ---
              GestureDetector(
                onTap: controller.addSocialField,
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: AppColors.primaryTextColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add another social link",
                      style: getTextStyle(
                        fontsize: 14,
                        fontweight: FontWeight.w500,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Obx(
                () => CustomPrimaryButton(
                  buttonText: controller.isLoading.value ? 'Creating...' : 'Next',
                  onTap: () {
                    if (!controller.isLoading.value) {
                      _createProfileAndShowSuccess(context, controller);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createProfileAndShowSuccess(
    BuildContext context,
    ProfileSetupController controller,
  ) async {
    final success = await controller.createProfile();
    if (success) {
      showProfileSuccessPopup(context);
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
}