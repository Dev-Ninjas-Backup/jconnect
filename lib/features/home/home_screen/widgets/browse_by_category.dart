import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

import '../controller/home_controller.dart';

class BrowseByCategorySection extends StatelessWidget {
  final HomeController controller;

  const BrowseByCategorySection({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <_CategoryCardData>[
      _CategoryCardData(
        title: 'Social Posts',
        subtitle: 'Get dedicated posts',
        icon: Icons.image,
        gradient: const [Color(0xFF3A0B10), Color(0xFF5A1018), Color(0xFF5A1018), Color(0xFF5A1018), Color(0xFF5A1018)],
      ),
      _CategoryCardData(
        title: 'Reposts',
        subtitle: 'Quick visibility boost',
        icon: Icons.repeat,
        gradient: const [Color(0xFF6B0E14), Color(0xFF8B141D),Color(0xFF8B141D), Color(0xFF8B141D), Color(0xFF8B141D)],
      ),
      _CategoryCardData(
        title: 'Services',
        subtitle: 'Get work done',
        icon: Icons.work_outline,
        gradient: const [Color(0xFF191535), Color(0xFF241C4D), Color(0xFF241C4D), Color(0xFF241C4D), Color(0xFF241C4D)],
      ),
    ];

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by Category',
                style: getTextStyle(
                  fontsize: sp(17),
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor,
                ),
              ),
       
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              for (int i = 0; i < categories.length; i++) ...[
                Expanded(
                  child: _CategoryCard(
                    data: categories[i],
                    isSelected: controller.selectedCategoryIndex.value == i,
                    onTap: () => controller.selectCategory(i),
                  ),
                ),
                if (i != categories.length - 1) SizedBox(width: 8.w),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryCardData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryTextColor
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.redColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              color: AppColors.primaryTextColor,
              size: sp(35),
            ),
            SizedBox(height: 5.h),
            Text(
              data.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontsize: sp(12),
                fontweight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontsize: sp(9),
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _CategoryCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}
