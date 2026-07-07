import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/repost/repost_process_option/controller/repost_process_option_controller.dart';
import 'package:jconnect/features/repost/repost_process_option/screens/repost_comtent_payment_screen.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../controller/artists_details_controller.dart';
import '../model/repost_listing_model.dart';

class RepostsSection extends StatelessWidget {
  RepostsSection({super.key, required this.controller});

  final ArtistsDetailsController controller;
  final RxBool _isExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<RepostListingModel> visiblePosts = controller.reposts;

      if (visiblePosts.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              "No Reposts Available",
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
            itemCount: _isExpanded.value
                ? visiblePosts.length
                : (visiblePosts.length > 3 ? 3 : visiblePosts.length),
            itemBuilder: (_, index) {
              var item = visiblePosts[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.backGroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade800, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
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
                        child: Image.asset(
                          item.platformIcon,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.repeat_rounded,
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
                          // Title row with price tag
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.platformDisplayName,
                                  style: getTextStyle(
                                    fontsize: 15,
                                    fontweight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${item.formattedFollowerCount} Followers  •  ${item.formattedTurnaround}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontsize: 11,
                              fontweight: FontWeight.w400,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          //   SizedBox(height: 6.h),
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

                    // Price + Buy Repost button
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
                                    final option = RepostOption(
                                      title: item.platformDisplayName,
                                      price:
                                          '\$${item.price.toStringAsFixed(2)}',
                                      badge: 'Active',
                                      listingId: item.id,
                                      followerCount: item.followerCount,
                                      description: item.description,
                                      defaultTurnaround: item.defaultTurnaround,
                                      rawPlatform: item.platform,
                                    );

                                    final platform = RepostPlatform(
                                      name: item.platformDisplayName.split(' ').first,
                                      iconPath: item.platformIcon,
                                      heroTitle: item.platformDisplayName,
                                      heroSubtitle: item.description,
                                      visualTag: item.platformDisplayName
                                          .split(' ')
                                          .first,
                                      repostTypes: [item.platformDisplayName],
                                      repostOptions: [option],
                                    );

                                    final procController = Get.put(
                                      RepostProcessOptionController(),
                                    );
                                    procController.platform.value = platform;
                                    procController.selectedOptionIndex.value =
                                        0;

                                    Get.to(
                                      () => RepostContentPaymentScreen(
                                        listingId: item.id.toString(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
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
                                      'Buy Repost',
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
          // View all reposts link
          if (visiblePosts.length > 3)
            GestureDetector(
              onTap: () {
                _isExpanded.value = !_isExpanded.value;
              },
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isExpanded.value
                          ? 'Show less'
                          : 'View all repost options (${visiblePosts.length})',
                      style: getTextStyle(
                        fontsize: 13,
                        fontweight: FontWeight.w500,
                        color: AppColors.redColor,
                      ),
                    ),
                    Icon(
                      _isExpanded.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: AppColors.redColor,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
