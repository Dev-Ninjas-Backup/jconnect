import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/custom_app_bar2.dart';

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
      case 'twitter':
        return Iconpath.twitter;
      case 'linkedin':
        return Iconpath.linkedIn;
      case 'snapchat':
        return Iconpath.snapChat;
      case 'twitch':
        return Iconpath.twitch;
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
            title: "User Details",
            leadingIconUrl: Iconpath.backIcon,
            onLeadingTap: Get.back,
          ),
          SizedBox(height: 34.h),

          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(100.r),
                  child: Image.network(
                    artist.profilePhoto ?? '',
                    height: 130.h,
                    width: 130.w,
                    fit: BoxFit.cover,

                    errorBuilder: (_, __, ___) => ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(100.r),
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
                  artist.userName.trim().isEmpty
                      ? "Unknown User"
                      : artist.userName,
                  style: getTextStyle(
                    fontsize: sp(24),
                    fontweight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() {
                  final isOwnProfile = controller.isOwnProfile(artist.id);
                  final isFollowing =
                      controller.followingUsers[artist.id] ?? false;

                  if (isOwnProfile) {
                    return Text(
                      "Your Own Profile",

                      style: getTextStyle(
                        fontsize: sp(12),
                        fontweight: FontWeight.w400,
                        color: AppColors.primaryTextColor.withValues(alpha: .5),
                      ),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${artist.followerCount} Followers',
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w500,
                          color: AppColors.primaryTextColor.withValues(
                            alpha: .7,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Opacity(
                        opacity: isFollowing ? 1.0 : 0.5,
                        child: CustomPrimaryButton(
                          buttonHeight: 4,
                          buttonWidth: 12,
                          buttonText: isFollowing ? 'Following' : 'Follow',
                          onTap: () {
                            controller.followUser(artist.id);
                          },
                        ),
                      ),
                    ],
                  );
                }),
                // Text(
                //   artist.email,
                //   style: getTextStyle(
                //     fontsize: sp(18),
                //     fontweight: FontWeight.w400,
                //     color: AppColors.primaryTextColor.withValues(alpha: .7),
                //   ),
                // ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
              ),
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
            "About ${artist.userName}",
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
          SizedBox(height: 40.h),

          Text(
            'Hash Tags',
            style: getTextStyle(
              fontsize: sp(18),
              fontweight: FontWeight.w500,
              color: AppColors.primaryTextColor.withValues(alpha: .7),
            ),
          ),
          SizedBox(height: 12.h),

          // Display hashtags
          if (artist.hashTags.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: artist.hashTags.map<Widget>((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTextColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primaryTextColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: getTextStyle(
                      fontsize: sp(12),
                      fontweight: FontWeight.w500,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              "No hashtags available",
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
