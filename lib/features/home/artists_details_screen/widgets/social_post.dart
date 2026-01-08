import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/routes/approute.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';
import '../controller/artists_details_controller.dart';

class SocialPost extends StatelessWidget {
  SocialPost({super.key, required this.controller});

  final ArtistsDetailsController controller;
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.socialPosts.length,
      itemBuilder: (_, index) {
        var item = controller.socialPosts[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: GradientBorderContainer(
            borderRadius: 8.r,
            borderWidth: .75,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(width: 12.w),
                    Text(
                      item.serviceName,
                      style: getTextStyle(
                        fontsize: sp(16),
                        fontweight: FontWeight.w500,
                      ),
                    ),
                    Image.network(item.socialLogoForSocialService.toString(), height: 30.h, width: 30.w,
                    
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image,size: 30.sp,color: Colors.white,),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  item.description,
                  style: getTextStyle(
                    fontsize: sp(10),
                    fontweight: FontWeight.w400,
                    color: AppColors.primaryTextColor.withValues(alpha: .5),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Expanded(
                      child: Text(
                        "\$ ${item.price.toStringAsFixed(2)}/promotion",
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w400,
                          color: AppColors.primaryTextColor.withValues(
                            alpha: .7,
                          ),
                        ),
                      ),
                    ),

                    Obx(() {
                      final artistId = controller.artistsDetails.value?.id;
                      final userId = controller.userId.value;

                      if (artistId == null || userId == null) {
                        return const SizedBox();
                      }

                      return artistId == userId
                          ? const SizedBox()
                          : CustomPrimaryButton(
                              buttonHeight: 10.h,
                              buttonWidth: 75.w,
                              buttonText: "Buy Post",
                              onTap: () {
                                Get.toNamed(
                                  AppRoute.getRequestServiceScreen(),
                                  arguments: item,
                                );
                              },
                            );
                    }),

                    // controller.artistsDetails.value!.id ==  pref.getUserId()
                    //     ? SizedBox()
                    //     : CustomPrimaryButton(
                    //         buttonHeight: 10.h,
                    //         buttonWidth: 75.w,

                    //         buttonText: "Buy Post",
                    //         onTap: () {
                    //           // Get.toNamed(AppRoute.getBuySocialcPost());\
                    //           Get.toNamed(
                    //             AppRoute.getRequestServiceScreen(),
                    //             arguments: item,
                    //           );
                    //         },
                    //       ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
