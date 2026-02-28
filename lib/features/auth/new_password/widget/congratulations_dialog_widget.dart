import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class CongratulationsDialog extends StatelessWidget {
  final bool isResetMode;

  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  CongratulationsDialog({super.key, this.isResetMode = false});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(Iconpath.checKIcon, height: 40, width: 40),
            ),
            SizedBox(height: 24),
            Text(
              "Congratulations!",
              style: getTextStyle(
                fontsize: 20,
                fontweight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              isResetMode
                  ? "Your password has been reset"
                  : "Your account is ready to use",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            CustomPrimaryButton(
              buttonText: 'Continue',
              onTap: () async {
                await pref.clearAllData();
                Get.offAllNamed('/loginScreen');
              },
            ),
          ],
        ),
      ),
    );
  }
}
