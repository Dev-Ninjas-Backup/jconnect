import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Let's Build Your Profile",
                style: getTextStyle(
                  fontsize: 22,
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                'Share who you are and what you do, this helps others connect with you faster.',
                style: getTextStyle(
                  fontsize: 14,
                  fontweight: FontWeight.w500,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              SizedBox(height: 32),

              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Upload Profile Image',
                  style: getTextStyle(
                    fontsize: 16,
                    fontweight: FontWeight.w500,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),
              SizedBox(height: 18),
              Container(
                height: size.height * 0.17,
                width: size.width * 0.39,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: AssetImage(Imagepath.profileImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
