import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/user_profile/help_and_support/contact_us/screen/contact_support_screen.dart';
import 'package:jconnect/features/user_profile/help_and_support/disputes/screen/dispute_screen.dart';
import 'package:jconnect/features/user_profile/help_and_support/frequently_asked_questions/screen/frequently_asked_questions_screen.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Custom AppBar
              CustomAppBar2(
                title: 'Help And Support',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 22.h),
              Text(
                "Need Help? We're here for you",
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 18,
                  fontweight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Get answers, open a dispute, or reach out to our support team directly',
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 12,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12.h),

              Column(
                children: [
                  _menuTile('FAQ\'s'),
                  SizedBox(height: 8.h),
                  _menuTile('Contact Support'),
                  SizedBox(height: 8.h),

                  _menuTile('Disputes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(String title) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontsize: 16,
            fontweight: FontWeight.w400,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primaryTextColor,
        ),
        onTap: () {
          Get.to(FrequentlyAskedQuestionsScreen());
          // Switch case logic
          switch (title) {
            case 'FAQ\'s':
              _openFAQ();
              break;
            case 'Contact Support':
              _contactSupport();
              break;
            case 'Disputes':
              _openDisputes();
              break;
            default:
          }
        },
      ),
    );
  }

  void _openFAQ() {
    Get.to(() => FrequentlyAskedQuestionsScreen());
  }

  void _contactSupport() {
    Get.to(() => ContactSupportScreen());
  }

  void _openDisputes() {
    Get.to(() => MyDisputesScreen());
  }
}
