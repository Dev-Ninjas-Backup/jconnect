import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String buttonText;
  final double? fontSize;
  final VoidCallback onTap;
  final double? buttonHeight;
  final double? buttonWidth;
  const CustomPrimaryButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.fontSize,
    this.buttonHeight,
    this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 96, 0, 15),
            Color.fromARGB(255, 187, 2, 36),
            Color.fromARGB(255, 96, 0, 15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.01, 0.5, 1.1],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(buttonWidth ?? double.infinity, buttonHeight ?? 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          buttonText,

          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontsize: fontSize ?? 16,
          ),
        ),
      ),
    );
  }
}
