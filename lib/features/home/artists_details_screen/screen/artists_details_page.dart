import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import '../widgets/artists_details_upper_section.dart';
import '../widgets/review_and_rating.dart';
import '../widgets/services.dart';
import '../widgets/social_post.dart';
import '../widgets/reposts_section.dart';

class ArtistsDetailsPage extends StatelessWidget {
  const ArtistsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ArtistsDetailsController>();
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final artist = controller.artistsDetails.value;
                  if (artist == null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 200.h),
                        child: CircularProgressIndicator(
                          color: AppColors.redColor,
                        ),
                      ),
                    );
                  }
                  return ArtistsDetailsUpperSection(controller: controller);
                }),

                SizedBox(height: 24.h),

                // Visibility Options header
                Text(
                  'Visibility Options',
                  style: getTextStyle(
                    fontsize: 16,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 12.h),

                // Three-tab selector: Social Posts | Reposts | Services
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.grey.shade800, width: 1),
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: Obx(
                    () => Row(
                      children: [
                        _buildTab(
                          icon: Icons.photo_library_outlined,
                          label: 'Social Posts',
                          isActive:
                              controller.selectSocialOrService.value ==
                              'social',
                          onTap: () {
                            controller.selectSocialOrService.value = 'social';
                          },
                        ),
                        SizedBox(width: 4.w),
                        _buildTab(
                          icon: Icons.repeat_rounded,
                          label: 'Reposts',
                          isActive:
                              controller.selectSocialOrService.value ==
                              'repost',
                          onTap: () {
                            controller.selectSocialOrService.value = 'repost';
                          },
                        ),
                        SizedBox(width: 4.w),
                        _buildTab(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Services',
                          isActive:
                              controller.selectSocialOrService.value ==
                              'service',
                          onTap: () {
                            controller.selectSocialOrService.value = 'service';
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Content area based on selected tab
                Obx(() {
                  final tab = controller.selectSocialOrService.value;
                  if (tab == 'social') {
                    return SocialPost(controller: controller);
                  } else if (tab == 'repost') {
                    return RepostsSection(controller: controller);
                  } else {
                    return Services(controller: controller);
                  }
                }),

                SizedBox(height: 30.h),

                // Review & Rating section header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Review & Rating",
                        style: getTextStyle(
                          fontsize: 18,
                          fontweight: FontWeight.w600,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.redColor,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            controller.artistsDetails.value?.averageRating
                                    .toString() ??
                                '0.0',
                            style: getTextStyle(
                              fontsize: 14,
                              fontweight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "(${controller.artistsDetails.value?.reviewsReceived.length ?? 0} reviews)",
                            style: getTextStyle(
                              fontsize: 12,
                              fontweight: FontWeight.w400,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                ReviewAndRating(controller: controller),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      Color.fromARGB(255, 96, 0, 15),
                      Color.fromARGB(255, 187, 2, 36),
                      Color.fromARGB(255, 96, 0, 15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontsize: 12,
                    fontweight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
