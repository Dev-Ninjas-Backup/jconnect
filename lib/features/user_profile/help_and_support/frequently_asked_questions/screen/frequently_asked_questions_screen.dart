import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/user_profile/help_and_support/contact_us/screen/contact_support_screen.dart';

class FrequentlyAskedQuestionsScreen extends StatelessWidget {
  const FrequentlyAskedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar
              CustomAppBar2(
                title: 'FAQs',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 22.h),

              // FAQ List
              Expanded(
                child: ListView(
                  children: [
                    _menuTile('How do I get paid for my promotions?'),
                    _menuTile('When can I withdraw my earnings?'),
                    _menuTile('Why is 10% deducted from my total earnings?'),
                    _menuTile(
                      'How do I accept or decline a promotion request?',
                    ),
                    _menuTile(
                      'What proof do I need to submit after completing a promotion?',
                    ),
                    _menuTile('Can I cancel a deal after accepting it?'),
                    _menuTile('What if the buyer cancels after payment?'),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
              CustomPrimaryButton(
                buttonText: 'Chat For Suport',
                onTap: () {
                  Get.to(ContactSupportScreen());
                },
              ),

              SizedBox(height: 8.h),
              Text(
                "Didn't find your answer? Get Help from Support",
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 12,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(String title) {
    return Padding(
      padding: EdgeInsets.all(6.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryTextColor),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(6),
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
            switch (title) {
              case 'How do I get paid for my promotions?':
                _showFAQDetail(
                  title,
                  'You get paid via XYZ method after completing your promotion.',
                );
                break;
              case 'When can I withdraw my earnings?':
                _showFAQDetail(
                  title,
                  'Withdrawals can be requested once your balance reaches \$X.',
                );
                break;
              case 'Why is 10% deducted from my total earnings?':
                _showFAQDetail(
                  title,
                  'The 10% is a platform fee for maintenance and support.',
                );
                break;
              case 'How do I accept or decline a promotion request?':
                _showFAQDetail(
                  title,
                  'Go to Promotions > Requests, and choose Accept or Decline.',
                );
                break;
              case 'What proof do I need to submit after completing a promotion?':
                _showFAQDetail(
                  title,
                  'Submit screenshots, links, or reports depending on the promotion type.',
                );
                break;
              case 'Can I cancel a deal after accepting it?':
                _showFAQDetail(
                  title,
                  'Cancellation is only allowed within 24 hours of acceptance.',
                );
                break;
              case 'What if the buyer cancels after payment?':
                _showFAQDetail(
                  title,
                  'Refunds are automatically processed according to our policy.',
                );
                break;
              default:
                print('No action defined for $title');
            }
          },
        ),
      ),
    );
  }

  void _showFAQDetail(String question, String answer) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        title: Text(
          question,
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontsize: 16,
            fontweight: FontWeight.w500,
          ),
        ),
        content: Text(
          answer,
          style: getTextStyle(
            color: AppColors.secondaryTextColor,
            fontsize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: getTextStyle(
                color: AppColors.redAccent,
                fontsize: 14,
                fontweight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
