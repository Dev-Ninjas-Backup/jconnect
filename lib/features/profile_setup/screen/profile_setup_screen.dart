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
          padding: EdgeInsets.all(16),
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

              SizedBox(height: 32),

              Text(
                'Upload Profile Image',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 18),

              ProfileImage(controller: controller, size: size),

              SizedBox(height: 32),

              Text(
                'Add Short Bio',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 12),

              CustomTextfield(
                hintText:
                    'DJ + Producer • Passionate about mixing beats and connecting vibes.',
              ),

              SizedBox(height: 8),
              Text(
                'Tip: Keep it short, describe your role and what makes your style unique.',
                style: getTextStyle(
                  fontsize: 12,
                  fontweight: FontWeight.w400,
                  color: AppColors.secondaryTextColor,
                ),
              ),

              SizedBox(height: 32),

              Text(
                'Link your socials',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),

              _buildSocialField(
                iconPath: 'assets/icons/instagram.png',
                hintText: 'Profile URL / Username',
              ),
              const SizedBox(height: 12),

              _buildSocialField(
                iconPath: 'assets/icons/facebook.png',
                hintText: 'Profile URL / Username',
              ),
              const SizedBox(height: 12),

              _buildSocialField(
                iconPath: 'assets/icons/tiktok.png',
                hintText: 'Profile URL / Username',
              ),
              const SizedBox(height: 12),

              _buildSocialField(
                iconPath: 'assets/icons/youtube.png',
                hintText: 'Channel URL / Channel Name',
              ),

              const SizedBox(height: 40),

              CustomPrimaryButton(
                buttonText: 'Next',
                onTap: () => showProfileSuccessPopup(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialField({
    required String iconPath,
    required String hintText,
  }) {
    return Row(
      children: [
        Image.asset(iconPath, height: 24, width: 24),
        const SizedBox(width: 12),
        Expanded(child: CustomTextfield(hintText: hintText)),
      ],
    );
  }

  void showProfileSuccessPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Text(
                "You’re all set!",
                style: getTextStyle(
                  fontsize: 22,
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Your profile is live. You can now explore top artists, and creators, or start offering your own services.",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontsize: 14,
                  fontweight: FontWeight.w500,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              SizedBox(height: 28),

              CustomPrimaryButton(
                buttonText: 'Browse Feed',
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoute.navBarScreen);
                },
              ),
              SizedBox(height: 12),
              CustomSecondaryButton(
                buttonText: 'Add Your Services',
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoute.addServiceScreen);
                },
              ),

              SizedBox(height: 16),
              Text(
                "You can always edit your profile or add more services later from your Profile tab.",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontsize: 12,
                  fontweight: FontWeight.w400,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
