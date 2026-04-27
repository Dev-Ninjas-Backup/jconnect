import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomPrimaryButton2 extends StatelessWidget {
  final String buttonText;
  final double? fontSize;
  final VoidCallback onTap;
  final double? buttonHeight;
  final double? buttonWidth;
  final List<Color>? gradientColor;
  const CustomPrimaryButton2({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.fontSize,
    this.buttonHeight,
    this.buttonWidth,
    this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight ?? 48,
      width: buttonWidth ?? double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                gradientColor ??
                [
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
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
      ),
    );
  }
}
