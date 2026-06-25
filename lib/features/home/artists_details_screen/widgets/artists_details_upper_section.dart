import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/iconpath.dart';
import '../../../../core/common/style/global_text_style.dart';

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

      if (artist == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final socialProfiles = artist.profile?.socialProfiles ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          CustomAppBar2(
            title: "",
            onLeadingTap: () => Get.back(),
            leadingIconUrl: Iconpath.backIcon,
          ),
          SizedBox(height: 20.h),

          // Profile photo centered
          Center(
            child: Column(
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade700, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60.r),
                    child: Image.network(
                      artist.profilePhoto ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: Icon(
                          Icons.person,
                          size: 60.sp,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Username with verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      artist.userName.trim().isEmpty
                          ? "Unknown User"
                          : artist.userName,
                      style: getTextStyle(
                        fontsize: 22,
                        fontweight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (artist.isVerified) ...[
                      SizedBox(width: 6.w),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.redColor,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),

                // Rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: AppColors.redColor, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${artist.averageRating}',
                      style: getTextStyle(
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '(${artist.reviewsReceived.length} review${artist.reviewsReceived.length != 1 ? 's' : ''})',
                      style: getTextStyle(
                        fontsize: 12,
                        fontweight: FontWeight.w400,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Followers + Follow button
                Obx(() {
                  final isOwnProfile = controller.isOwnProfile(artist.id);
                  final isFollowing =
                      controller.followingUsers[artist.id] ?? false;

                  if (isOwnProfile) {
                    return Text(
                      "Your Own Profile",
                      style: getTextStyle(
                        fontsize: 12,
                        fontweight: FontWeight.w400,
                        color: AppColors.secondaryTextColor,
                      ),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${artist.followerCount} Followers',
                        style: getTextStyle(
                          fontsize: 14,
                          fontweight: FontWeight.w500,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      SizedBox(
                        width: 110.w,
                        child: CustomPrimaryButton(
                          buttonHeight: 36,
                          buttonText: isFollowing ? 'Following' : 'Follow',
                          fontSize: sp(13),
                          onTap: () {
                            controller.followUser(artist.id);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          // Social Links section
          Text(
            'Social Links',
            style: getTextStyle(
              fontsize: 16,
              fontweight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          SizedBox(height: 12.h),

          if (socialProfiles.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(socialProfiles.length, (index) {
                  final iconPath = getSocialIcon(
                    socialProfiles[index].platformName ?? '',
                  );

                  return Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: GestureDetector(
                      onTap: () {
                        final url = socialProfiles[index].platformLink;
                        if (url != null && url.isNotEmpty) {
                          controller.launchURL(url);
                        }
                      },
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.grey.shade700,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            height: 22.w,
                            width: 22.w,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )
          else
            Text(
              "No social profiles available",
              style: getTextStyle(
                fontsize: 12,
                color: AppColors.secondaryTextColor,
              ),
            ),

          SizedBox(height: 28.h),

          // About section
          Text(
            'About ${artist.userName}',
            style: getTextStyle(
              fontsize: 16,
              fontweight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            artist.profile?.shortBio ?? "No bio available",
            style: getTextStyle(
              fontsize: 13,
              color: AppColors.secondaryTextColor,
            ),
          ),

          SizedBox(height: 28.h),

          // Hash Tags section
          Text(
            'Hash Tags',
            style: getTextStyle(
              fontsize: 16,
              fontweight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          SizedBox(height: 12.h),

          if (artist.hashTags.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: artist.hashTags.map<Widget>((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.grey.shade700, width: 1),
                  ),
                  child: Text(
                    tag,
                    style: getTextStyle(
                      fontsize: 12,
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
                fontsize: 12,
                color: AppColors.secondaryTextColor,
              ),
            ),
        ],
      );
    });
  }
}
