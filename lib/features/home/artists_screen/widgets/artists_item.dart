// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import 'package:jconnect/features/home/artists_details_screen/screen/artists_service_list.dart';
import 'package:jconnect/features/home/artists_details_screen/screen/artists_social_post_list.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

// ignore: must_be_immutable
class ArtistsItem extends StatelessWidget {
  final ArtistsController controller;
  ArtistsItem({required this.controller, super.key});
  final HomeController homeController = Get.find<HomeController>();
  var artistsDetailsController = Get.put(
    ArtistsDetailsController(
      networkClient: NetworkClient(
        onUnAuthorize: () {
          if (kDebugMode) {
            print("unauthorized");
          }
        },
      ),
    ),
  );

  // List<ArtistsModel> get currentList {
  //   if (controller.searchArtistItems.isNotEmpty &&
  //       controller.searchTextController.text.trim().isNotEmpty) {
  //     return controller.searchArtistItems;
  //   }

  //   if (controller.selectArtistsItemIndex.value == 0) {
  //     return controller.artistsItems;
  //   }
  //  else if (controller.selectArtistsItemIndex.value == 1) {
  //     return homeController.recentArtistsList;
  //   }

  //  else if (controller.selectArtistsItemIndex.value == 2) {
  //     return homeController.topRatedArtistsList;
  //   }

  //   return homeController.suggestedForYouList;
  // }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        List<ArtistsModel> currentList;

        //  Search first
        if (controller.searchArtistItems.isNotEmpty &&
            controller.searchTextController.text.trim().isNotEmpty) {
          currentList = controller.searchArtistItems;
        }
        //  Tab index selection
        else if (controller.selectArtistsItemIndex.value == 0) {
          currentList = controller.artistsItems;
        } else if (controller.selectArtistsItemIndex.value == 1) {
          currentList = homeController.recentArtistsList;
        } else if (controller.selectArtistsItemIndex.value == 2) {
          currentList = homeController.topRatedArtistsList;
        } else {
          currentList = homeController.suggestedForYouList;
        }

        return GridView.builder(
          itemCount: currentList.length,
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 15,
            childAspectRatio: .4,
          ),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (_, index) {
            //  final item = controller.artistsItems[index];

            final artist = currentList[index];

            // Service info
            final firstService = artist.services.isNotEmpty
                ? artist.services.first
                : null;
            final serviceDesc =
                firstService?.description.trim().isNotEmpty == true
                ? firstService!.description
                : "No service description available";
            final servicePrice = (firstService?.price ?? 0).toDouble();

            // Rating
            final reviews = artist.reviewsReceived;
            final avgRating = reviews.isEmpty
                ? 0.0
                : reviews
                          .map((r) => r.rating!.toDouble())
                          .reduce((a, b) => a + b) /
                      reviews.length;

            return GestureDetector(
              onTap: () async {
                await artistsDetailsController.fetchArtistById(artist.id);
                Get.toNamed(AppRoute.artistsDetailsPage);
              },
              child: GradientBorderContainer(
                width: double.infinity,
                borderRadius: 10.r,
                borderWidth: 1,
                gradientColors: [Colors.white, Colors.white.withOpacity(0.5)],
                padding: EdgeInsetsGeometry.zero,
                // EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile photo
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),
                      child:
                          artist.profilePhoto != null &&
                              artist.profilePhoto!.trim().isNotEmpty
                          ? Image.network(
                              artist.profilePhoto!,
                              height: 112.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Icon(
                                  Icons.broken_image,
                                  size: 112,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: 12.h),

                    /// Name + price
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              artist.userName.trim().isEmpty
                                  ? "Unknown User"
                                  : artist.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontsize: sp(16),
                                fontweight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                width: 0.25,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            child: Text(
                              "From \$${servicePrice.toStringAsFixed(2)}",
                              style: getTextStyle(
                                fontsize: sp(8),
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        "Services",
                        style: getTextStyle(
                          fontsize: sp(10),
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 6.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        serviceDesc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          fontsize: sp(10),
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    /// Rating
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RatingBarIndicator(
                            rating: avgRating,
                            itemBuilder: (_, __) => const Icon(
                              Icons.star,
                              color: Color(0xffBD001F),
                            ),
                            itemCount: 5,
                            itemSize: 14,
                            unratedColor: const Color(0xFFD96B7D),
                          ),
                          Text(
                            "${avgRating.toStringAsFixed(1)} (${reviews.length})",
                            style: getTextStyle(
                              fontsize: sp(10),
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: CustomPrimaryButton(
                        buttonText: "Buy A Service",
                        onTap: () async {
                          final artistsDetailsController = Get.put(
                            ArtistsDetailsController(
                              networkClient: NetworkClient(
                                onUnAuthorize: () {
                                  if (kDebugMode) {
                                    print("unauthorized");
                                  }
                                },
                              ),
                            ),
                          );
                          await artistsDetailsController.fetchArtistById(
                            artist.id,
                          );
                          Get.to(() => ArtistsServiceList());
                        },
                        fontSize: sp(10),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: CustomPrimaryButton(
                        buttonText: "Buy A Social Post",

                        onTap: () async {
                          final artistsDetailsController = Get.put(
                            ArtistsDetailsController(
                              networkClient: NetworkClient(
                                onUnAuthorize: () {
                                  if (kDebugMode) {
                                    print("unauthorized");
                                  }
                                },
                              ),
                            ),
                          );
                          await artistsDetailsController.fetchArtistById(
                            artist.id,
                          );
                          Get.to(() => ArtistsSocialPostList());
                        },

                        // onTap: () {
                        //   Get.to(() => ArtistsSocialPostList());
                        // },
                        fontSize: sp(10),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    /// Message button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      child: CustomPrimaryButton(
                        fontSize: sp(10),
                        buttonText: "Inquire",
                        onTap: () {
                          homeController.sendInquiry(userID: artist.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
