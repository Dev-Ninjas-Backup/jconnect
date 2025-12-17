import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import '../widgets/artists_details_upper_section.dart';
import '../widgets/review_and_rating.dart';
import '../widgets/services.dart';
import '../widgets/social_post.dart';

class ArtistsDetailsPage extends StatelessWidget {
  const ArtistsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // var controller = Get.put(ArtistsDetailsController());
    // var controller = Get.put(
    //   ArtistsDetailsController(
    //     networkClient: NetworkClient(
    //       onUnAuthorize: () {
    //         if (kDebugMode) {
    //           print("unauthorized");
    //         }
    //       },
    //     ),
    //   ),
    // );
    var controller = Get.find<ArtistsDetailsController>();
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Obx(() {
                final artist = controller.artistsDetails.value;
                if (artist == null) {
                  return Center(child: CircularProgressIndicator());
                }
                return ArtistsDetailsUpperSection(controller: controller);
              }),

              // ArtistsDetailsUpperSection(controller: controller,),
              SizedBox(height: 30.h),

              GradientBorderContainer(
                borderRadius: 8.r,
                borderWidth: .5,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 30.w,
                    children: [
                      Expanded(
                        child: CustomSecondaryButton(
                          gradientColors: [
                            Color.fromARGB(255, 96, 0, 15),
                            Color.fromARGB(255, 187, 2, 36),
                            Color.fromARGB(255, 96, 0, 15),
                          ],
                          buttonText: "Social Post",
                          isActive:
                              controller.selectSocialOrService.value ==
                              'social',
                          onTap: () {
                            controller.selectSocialOrService.value = "social";
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomSecondaryButton(
                          gradientColors: [
                            Color.fromARGB(255, 96, 0, 15),
                            Color.fromARGB(255, 187, 2, 36),
                            Color.fromARGB(255, 96, 0, 15),
                          ],
                          buttonText: "Services",
                          isActive:
                              controller.selectSocialOrService.value ==
                              'service',
                          onTap: () {
                            controller.selectSocialOrService.value = "service";
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Obx(
                () => controller.selectSocialOrService.value == "social"
                    ? SocialPost(controller: controller)
                    : Services(controller: controller),
              ),

              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Review & Rating",
                    style: getTextStyle(
                      fontsize: sp(18),
                      fontweight: FontWeight.w500,
                      color: AppColors.primaryTextColor.withValues(alpha: .70),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.primaryTextColor,
                        size: sp(14),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        controller.artistsDetails.value!.averageRating
                            .toString(),
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w500,
                          color: AppColors.primaryTextColor.withValues(
                            alpha: .70,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "(${controller.artistsDetails.value?.reviewsReceived.length}) reviews",
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w500,
                          color: AppColors.primaryTextColor.withValues(
                            alpha: .70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              ReviewAndRating(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
