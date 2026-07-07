import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/routes/approute.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../controller/artists_details_controller.dart';

class SocialPost extends StatelessWidget {
  SocialPost({super.key, required this.controller});

  final ArtistsDetailsController controller;
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  @override
  Widget build(BuildContext context) {
    // Only show social posts that are not custom (isCustom == false)
    final visiblePosts = controller.socialPosts.where((p) {
      try {
        return p.isCustom == false;
      } catch (_) {
        return true;
      }
    }).toList();

    if (visiblePosts.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            "No Social Posts Available",
            style: getTextStyle(
              fontsize: 14,
              fontweight: FontWeight.w500,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: visiblePosts.length > 3 ? 3 : visiblePosts.length,
          itemBuilder: (_, index) {
            var item = visiblePosts[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.backGroundColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade800,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Social platform icon
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Image.network(
                        item.socialLogoForSocialService.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.photo_library_outlined,
                          size: 24.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Content column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.serviceName,
                          style: getTextStyle(
                            fontsize: 15,
                            fontweight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                            fontsize: 11,
                            fontweight: FontWeight.w400,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        // SizedBox(height: 6.h),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.verified_outlined,
                        //       size: 14.sp,
                        //       color: AppColors.secondaryTextColor,
                        //     ),
                        //     SizedBox(width: 4.w),
                        //     Text(
                        //       'Verification Included',
                        //       style: getTextStyle(
                        //         fontsize: 11,
                        //         color: AppColors.secondaryTextColor,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Price + Buy button column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: getTextStyle(
                          fontsize: 16,
                          fontweight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(() {
                        final artistId = controller.artistsDetails.value?.id;
                        final userId = controller.userId.value;

                        if (artistId == null || userId == null) {
                          return const SizedBox();
                        }

                        return artistId == userId
                            ? const SizedBox()
                            : GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    AppRoute.getRequestServiceScreen(),
                                    arguments: item,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 96, 0, 15),
                                        Color.fromARGB(255, 187, 2, 36),
                                        Color.fromARGB(255, 96, 0, 15),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Buy Post',
                                    style: getTextStyle(
                                      fontsize: 11,
                                      fontweight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                      }),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        // View all link
        if (visiblePosts.length > 3)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View all post options (${visiblePosts.length})',
                  style: getTextStyle(
                    fontsize: 13,
                    fontweight: FontWeight.w500,
                    color: AppColors.redColor,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.redColor,
                  size: 14.sp,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
