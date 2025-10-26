import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomSecondaryButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;

  const CustomSecondaryButton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryTextColor, width: 1),
          color: Colors.transparent,
        ),
        child: Text(
          buttonText,
          style: getTextStyle(
            fontsize: 16,
            fontweight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
      ),
    );
  }
}
