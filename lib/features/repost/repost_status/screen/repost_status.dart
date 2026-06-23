import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_status/controller/repost_status_controller.dart';
import 'package:jconnect/features/repost/repost_status/widgets/repost_status_card.dart';

class RepostStatuScreen extends StatelessWidget {
  const RepostStatuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RepostStatusController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── App Bar ────────────────────────────────────────────
              CustomAppBar2(
                title: 'Reposts Status',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),

              SizedBox(height: 20.h),

              // ─── Tab Bar ─────────────────────────────────────────────
              _RepostTabBar(controller: controller),

              SizedBox(height: 20.h),

              // ─── List ─────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  final list = controller.currentList;
                  final isPaidTab = controller.selectedTab.value == RepostTab.paidRepost;

                  if (list.isEmpty) {
                    return _EmptyState(isPaidTab: isPaidTab);
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) => RepostStatusCard(
                      item: list[index],
                      isPaidTab: isPaidTab,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _RepostTabBar extends StatelessWidget {
  final RepostStatusController controller;
  const _RepostTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: RepostTab.values.map((tab) {
            final isSelected = controller.selectedTab.value == tab;
            final label = tab == RepostTab.myRepost ? 'My Repost' : 'Paid Repost';
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF60000F),
                              Color(0xFFBB0224),
                              Color(0xFF60000F),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontsize: 13,
                      fontweight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primaryTextColor
                          : AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isPaidTab;
  const _EmptyState({required this.isPaidTab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPaidTab ? Icons.receipt_long_rounded : Icons.repeat_rounded,
            size: 60.r,
            color: AppColors.secondaryTextColor,
          ),
          SizedBox(height: 16.h),
          Text(
            isPaidTab ? 'No paid reposts yet' : 'No repost requests yet',
            style: getTextStyle(
              fontsize: 16,
              fontweight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isPaidTab
                ? 'Your paid repost requests\nwill appear here.'
                : 'Repost requests assigned\nto you will appear here.',
            textAlign: TextAlign.center,
            style: getTextStyle(color: AppColors.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
