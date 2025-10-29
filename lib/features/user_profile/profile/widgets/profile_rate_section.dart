import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';

class ProfileRateSection extends StatelessWidget {
  final ProfileController controller;

  const ProfileRateSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Platform Rates',
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontweight: FontWeight.bold,
              fontsize: 18,
            ),
          ),
          SizedBox(height: 10),
          ...controller.rates.asMap().entries.map((entry) {
            final rate = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.backGroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondaryTextColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rate.title,
                          style: getTextStyle(
                            color: AppColors.primaryTextColor,
                            fontweight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          rate.description,
                          style: getTextStyle(
                            color: AppColors.secondaryTextColor,
                            fontsize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${rate.price.toStringAsFixed(0)}',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontweight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.edit_document,
                      color: AppColors.primaryTextColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: controller.addNewRate,
              child: Text(
                '+ Add more rates',
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontweight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
