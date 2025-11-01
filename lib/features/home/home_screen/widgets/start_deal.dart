import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';

class StartDeal extends StatelessWidget {
  final HomeController controller;
  const StartDeal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = screenWidth * 0.8;
    final cardHeight = screenHeight * 0.23;
    final padding = screenWidth * 0.04;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.startDealList.length,
        padding: EdgeInsets.symmetric(horizontal: padding),
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(right: padding),
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFBD001F),
                    Color(0xFF713AE6).withValues(alpha: .5),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 0.6,
                    vertical: padding,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🔥 Weekend Deal – 10% Off on All Deals!",
                        style: getTextStyle(
                          fontweight: FontWeight.w600,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: padding * 0.5),
                      Text(
                        "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
                        style: getTextStyle(
                          fontsize: 12,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: padding * 0.5),
                      CustomPrimaryButton(
                        buttonText: "Start Deal",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
