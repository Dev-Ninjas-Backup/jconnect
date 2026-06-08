import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../controller/artists_details_controller.dart';

class Services extends StatelessWidget {
  const Services({super.key, required this.controller});

  final ArtistsDetailsController controller;

  @override
  Widget build(BuildContext context) {
    // Only show services that are not custom (isCustom == false)
    final visibleServices = controller.services.where((s) {
      try {
        return s.isCustom == false;
      } catch (_) {
        return true;
      }
    }).toList();

    if (visibleServices.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            "No Services Available",
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
          itemCount:
              visibleServices.length > 3 ? 3 : visibleServices.length,
          itemBuilder: (_, index) {
            var item = visibleServices[index];
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
                  SizedBox(height: 6.h),
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
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: getTextStyle(
                          fontsize: 16,
                          fontweight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Obx(() {
                        final artistId =
                            controller.artistsDetails.value?.id;
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
                                    borderRadius:
                                        BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Request Service',
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

        // View all services link
        if (visibleServices.length > 3)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View all service options (${visibleServices.length})',
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
