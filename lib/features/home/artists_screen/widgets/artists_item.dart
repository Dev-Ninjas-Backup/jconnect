// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
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

            return GradientBorderContainer(
              // width: 213.w,
              borderRadius: 10.r,
              borderWidth: 1,
              gradientColors: [Colors.white, Colors.white.withOpacity(0.5)],
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo (Fixed: placeholder + error handling)
                  Center(
                    child: GestureDetector(
                      onTap: () async{
                        await artistsDetailsController.fetchArtistById(artist.id);
                        Get.toNamed(
                          AppRoute.artistsDetailsPage,
                          // arguments: artist.id
                        );
                      },

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child:
                            artist.profilePhoto != null &&
                                artist.profilePhoto!.trim().isNotEmpty
                            ? Image.network(
                                artist.profilePhoto!,
                                height: 80.h,
                                width: 80.w,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 80.h,
                                        width: 80.w,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Name + Price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artist.fullName.trim().isEmpty
                              ? "Unknown Artist"
                              : artist.fullName,
                          style: getTextStyle(
                            fontsize: sp(16),
                            fontweight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                          servicePrice > 0
                              ? "From \$${servicePrice.toStringAsFixed(0)}"
                              : "From \$0",
                          style: getTextStyle(
                            fontsize: sp(8),
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),
                  Text(
                    "Services",
                    style: getTextStyle(
                      fontsize: sp(10),
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    serviceDesc,

                    style: getTextStyle(
                      fontsize: sp(10),
                      color: AppColors.secondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 20.h),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingBarIndicator(
                        rating: avgRating,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: Color(0xffBD001F)),
                        itemCount: 5,
                        itemSize: 14.0,
                        direction: Axis.horizontal,
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

                  const Spacer(),

                  // Buttons
                  CustomPrimaryButton(
                    buttonText: "Message",
                    onTap: () => Get.toNamed(
                      AppRoute.chatDetailsScreen,
                      arguments: artist,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  CustomSecondaryButton(
                    buttonText: "Custom Order",
                    onTap: () {
                      Get.toNamed(AppRoute.customServices);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
