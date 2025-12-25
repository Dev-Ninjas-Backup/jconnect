import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_app_bar2.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
import '../../../../core/common/widgets/custom_secondary_button.dart';

// class ArtistsDetailsUpperSection extends StatelessWidget {
//   final ArtistsDetailsController controller;
//   const ArtistsDetailsUpperSection({super.key, required this.controller});
//   String getSocialIcon(String platform) {
//     switch (platform.toLowerCase()) {
//       case 'facebook':
//         return Iconpath.facebook;
//       case 'instagram':
//         return Iconpath.instagram;
//       case 'tiktok':
//         return Iconpath.tiktok;
//       case 'youtube':
//         return Iconpath.youtube;
//       default:
//         return Iconpath.defaultSocial;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CustomAppBar2(
//           title: "Artist Details",
//           leadingIconUrl: Iconpath.backIcon,
//           onLeadingTap: () {
//             Get.back();
//           },
//         ),
//         SizedBox(height: 34.h),

//         Center(
//           child: Column(
//             children: [
//               Image.network(
//                 controller.artistsDetails.value?.profilePhoto.toString() ?? " ",
//                 height: 130.w,
//                 width: 130.w,
//                 errorBuilder: (context, error, stackTrace) =>
//                     Icon(Icons.broken_image, size: 130, color: Colors.white),
//               ),
//               SizedBox(height: 12.h),
//               Text(
//                 controller.artistsDetails.value!.fullName,
//                 style: getTextStyle(
//                   fontsize: sp(24),
//                   fontweight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 controller.artistsDetails.value!.email,
//                 style: getTextStyle(
//                   fontsize: sp(10),
//                   fontweight: FontWeight.w400,
//                   color: AppColors.primaryTextColor.withValues(alpha: .7),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         SizedBox(height: 30.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           spacing: 24.w,
//           children: [
//             Expanded(
//               child: CustomSecondaryButton(buttonText: "Message", onTap: () {}),
//             ),
//             Expanded(
//               child: CustomPrimaryButton(
//                 buttonText: "Request Service",
//                 onTap: () {
//                   Get.toNamed(AppRoute.getRequestServiceScreen());
//                 },
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 40.h),
//         Text(
//           "Social Links:",
//           style: getTextStyle(
//             fontsize: sp(18),
//             fontweight: FontWeight.w500,
//             color: AppColors.primaryTextColor.withValues(alpha: .7),
//           ),
//         ),
//         SizedBox(height: 24.h),
//         Row(
//           children: List.generate(
//             controller.artistsDetails.value!.profile!.socialProfiles.length,
//             (index) {
//               final iconPath = getSocialIcon(
//                 controller
//                         .artistsDetails
//                         .value!
//                         .profile!
//                         .socialProfiles[index]
//                         .platformName ??
//                     " ",
//               );

//               return Padding(
//                 padding: EdgeInsets.only(right: 34.w),
//                 child: Image.asset(iconPath, height: 24.w, width: 24.w),
//               );
//             },
//           ),
//         ),

//         SizedBox(height: 40.h),
//         Text(
//           "About  ${controller.artistsDetails.value!.fullName.toString()}",
//           style: getTextStyle(
//             fontsize: sp(18),
//             fontweight: FontWeight.w500,
//             color: AppColors.primaryTextColor.withValues(alpha: .7),
//           ),
//         ),
//         SizedBox(height: 10.h),
//         Text(
//           controller.artistsDetails.value?.profile?.shortBio ??
//               "No bio available",
//           style: getTextStyle(
//             fontsize: sp(12),
//             color: AppColors.primaryTextColor.withValues(alpha: .5),
//           ),
//         ),
//       ],
//     );
//   }
// }

class ArtistsDetailsUpperSection extends StatelessWidget {
  final ArtistsDetailsController controller;
  const ArtistsDetailsUpperSection({super.key, required this.controller});

  String getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Iconpath.facebook;
      case 'instagram':
        return Iconpath.instagram;
      case 'tiktok':
        return Iconpath.tiktok;
      case 'youtube':
        return Iconpath.youtube;
      default:
        return Iconpath.defaultSocial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final artist = controller.artistsDetails.value;

      // ⛔ Loading state (prevents crash)
      if (artist == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final socialProfiles = artist.profile?.socialProfiles ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar2(
            title: "Artist Details",
            leadingIconUrl: Iconpath.backIcon,
            onLeadingTap: Get.back,
          ),
          SizedBox(height: 34.h),

          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(100),
                  child: Image.network(
                    artist.profilePhoto ?? '',
                    height: 130.w,
                    width: 130.w,
                    errorBuilder: (_, __, ___) => ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(50),
                      child: const Icon(
                        Icons.broken_image,
                        size: 130,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  artist.fullName,
                  style: getTextStyle(
                    fontsize: sp(24),
                    fontweight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  artist.email,
                  style: getTextStyle(
                    fontsize: sp(10),
                    fontweight: FontWeight.w400,
                    color: AppColors.primaryTextColor.withValues(alpha: .7),
                  ),
                ),
              ],
            ),
          ),

          // SizedBox(height: 30.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   spacing: 24.w,
          //   children: [
          //     Expanded(
          //       child: CustomSecondaryButton(
          //         buttonText: "Message",
          //         onTap: () {},
          //       ),
          //     ),
          //     Expanded(
          //       child: CustomPrimaryButton(
          //         buttonText: "Request Service",
          //         onTap: () {
          //      //     Get.toNamed(AppRoute.getRequestServiceScreen());
          //         },
          //         fontSize: 14,
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 40.h),
          Text(
            "Social Links:",
            style: getTextStyle(
              fontsize: sp(18),
              fontweight: FontWeight.w500,
              color: AppColors.primaryTextColor.withValues(alpha: .7),
            ),
          ),
          SizedBox(height: 24.h),

          if (socialProfiles.isNotEmpty)
            Row(
              children: List.generate(socialProfiles.length, (index) {
                final iconPath = getSocialIcon(
                  socialProfiles[index].platformName ?? '',
                );

                return Padding(
                  padding: EdgeInsets.only(right: 34.w),
                  child: GestureDetector(
                    onTap: () {
                      final url = socialProfiles[index].platformLink;
                      if (url != null && url.isNotEmpty) {
                        controller.launchURL(url);
                      }
                    },
                    child: Image.asset(iconPath, height: 24.w, width: 24.w),
                  ),
                );
              }),
            )
          else if (socialProfiles.isEmpty)
            Text(
              "No social profiles available",
              style: getTextStyle(
                fontsize: sp(12),
                color: AppColors.primaryTextColor.withValues(alpha: .5),
              ),
            ),

          SizedBox(height: 40.h),
          Text(
            "About ${artist.fullName}",
            style: getTextStyle(
              fontsize: sp(18),
              fontweight: FontWeight.w500,
              color: AppColors.primaryTextColor.withValues(alpha: .7),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            artist.profile?.shortBio ?? "No bio available",
            style: getTextStyle(
              fontsize: sp(12),
              color: AppColors.primaryTextColor.withValues(alpha: .5),
            ),
          ),
        ],
      );
    });
  }
}
