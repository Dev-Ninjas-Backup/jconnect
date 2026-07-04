import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/home/home_screen/model/spotlight_listings_model.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/repost/repost_start/screens/repost_screen.dart';

class SpotlightCard extends StatelessWidget {
  const SpotlightCard({super.key, required this.item, this.padding});

  final SpotlightListingModel item;
  final EdgeInsetsGeometry? padding;

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1).replaceFirst('.0', '')}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1).replaceFirst('.0', '')}K";
    }
    return count.toString();
  }

  Widget _buildPlatformIcon(String platform) {
    final p = platform.toUpperCase();
    String? assetPath;
    IconData? iconData;

    if (p.contains("INSTAGRAM")) {
      assetPath = Iconpath.instagram;
    } else if (p.contains("FACEBOOK")) {
      assetPath = Iconpath.facebook;
    } else if (p.contains("TIKTOK")) {
      assetPath = Iconpath.tiktok;
    } else if (p.contains("YOUTUBE")) {
      assetPath = Iconpath.youtube;
    } else if (p.contains("TWITTER") || p.contains("X")) {
      assetPath = Iconpath.twitter;
    } else if (p.contains("SNAPCHAT")) {
      assetPath = Iconpath.snapChat;
    } else if (p.contains("LINKEDIN")) {
      assetPath = Iconpath.linkedIn;
    } else if (p.contains("TWITCH")) {
      assetPath = Iconpath.twitch;
    } else {
      iconData = Icons.link;
    }

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: 14.w,
        height: 14.w,
        fit: BoxFit.contain,
      );
    } else {
      return Icon(iconData, size: 14.w, color: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(right: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(2.5.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.pink, Colors.purple],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 34.r,
                  backgroundColor: Colors.grey[900],
                  backgroundImage:
                      item.seller?.profilePhoto != null &&
                          item.seller!.profilePhoto!.trim().isNotEmpty
                      ? NetworkImage(item.seller!.profilePhoto!)
                            as ImageProvider
                      : AssetImage(Imagepath.profileImage) as ImageProvider,
                ),
              ),
              if (item.platform.isNotEmpty)
                Positioned(
                  bottom: 6,
                  right: -2,
                  child: Container(
                    padding: EdgeInsets.all(5.r),
                    clipBehavior: Clip.none,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: Color.fromARGB(255, 206, 190, 190),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildPlatformIcon(item.platform),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  item.seller?.username.trim().isEmpty == true
                      ? "User"
                      : item.seller!.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontsize: sp(12),
                    fontweight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (item.seller?.isProfileVerified == true) ...[
                SizedBox(width: 3.w),
                Icon(Icons.verified, color: Colors.red, size: sp(12)),
              ],
            ],
          ),

          Text(
            "${_formatFollowers(item.followerCount)} Followers",
            style: getTextStyle(
              fontsize: sp(10),
              color: AppColors.secondaryTextColor,
            ),
          ),
          SizedBox(height: 6.h),

          GestureDetector(
            onTap: () {
              Get.to(RepostScreen());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF60000F),
                    Color(0xFFBB0224),
                    Color(0xFF60000F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.red.shade900, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 12.r,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "\$${item.price.toInt()} REPOST",
                    style: getTextStyle(
                      fontsize: sp(9),
                      fontweight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
