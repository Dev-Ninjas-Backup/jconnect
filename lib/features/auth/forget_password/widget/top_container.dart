import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class TopContainer extends StatelessWidget {
  const TopContainer({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size * 0.25,
      decoration: BoxDecoration(
        color: AppColors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Imagepath.lockImage, height: 80, width: 80),
            SizedBox(height: 12),
            Text(
              'Select which contact details should we use to reset your password',
              style: getTextStyle(
                fontsize: 15,
                fontweight: FontWeight.w500,
                color: AppColors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
