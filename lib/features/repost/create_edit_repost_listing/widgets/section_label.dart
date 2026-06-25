import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: getTextStyle(
        fontsize: 14,
        fontweight: FontWeight.w500,
        color: AppColors.primaryTextColor,
      ),
      textAlign: TextAlign.left,
    );
  }
}
