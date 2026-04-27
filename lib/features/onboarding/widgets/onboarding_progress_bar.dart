import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import '../controller/onboarding_controller.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final total = controller.totalPages;
      final gap = 6.0;
      final totalGap = gap * (total - 1);
      final availableWidth = screenWidth - totalGap;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          double width;
          if (index < controller.currentPage.value) {
            width = availableWidth / total * 0.8;
          } else if (index == controller.currentPage.value) {
            width = availableWidth / total * 0.9;
          } else {
            width = availableWidth / total;
          }

          Color color;
          if (index < controller.currentPage.value) {
            color = AppColors.redColor;
          } else if (index == controller.currentPage.value) {
            color = Colors.white;
          } else {
            color = Colors.grey.shade800;
          }

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: gap / 2),
            height: 5,
            width: width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      );
    });
  }
}
