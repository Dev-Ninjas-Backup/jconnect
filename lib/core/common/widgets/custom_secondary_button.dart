// import 'package:flutter/material.dart';
// import 'package:jconnect/core/common/constants/app_colors.dart';
// import 'package:jconnect/core/common/style/global_text_style.dart';

// class CustomSecondaryButton extends StatelessWidget {
//   final String buttonText;
//   final VoidCallback onTap;
//   final List<Color>? gradientColors;
//   final bool isActive;
//   const CustomSecondaryButton({
//     super.key,
//     required this.buttonText,
//     required this.onTap,
//     this.gradientColors,
//     this.isActive = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 50,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: AppColors.primaryTextColor, width: 1),
//           // color: Colors.transparent,
//           gradient: LinearGradient(
//             colors: gradientColors ?? [Colors.transparent, Colors.transparent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             stops: [0.01, 0.5, 1.1],
//           ),
//         ),
//         child: Text(
//           buttonText,
//           style: getTextStyle(
//             fontsize: 16,
//             fontweight: FontWeight.w600,
//             color: AppColors.primaryTextColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomSecondaryButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final bool isActive;

  const CustomSecondaryButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.gradientColors,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasGradient =
        gradientColors != null && gradientColors!.length >= 2;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.primaryTextColor,
            width: 1.2,
          ),

          gradient: isActive && hasGradient
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive
              ? (hasGradient
                    ? null
                    : AppColors.primaryTextColor.withValues(alpha: 0.2))
              : Colors.transparent,
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
