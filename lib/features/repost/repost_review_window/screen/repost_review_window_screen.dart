import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_review_window/controller/repost_review_window_controller.dart';

class RepostReviewWindowScreen extends StatelessWidget {
  final RepostStatusItem item;
  const RepostReviewWindowScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RepostReviewWindowController(item: item));

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: Colors.white, size: 24.r),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Review Window',
                        style: getTextStyle(
                          fontsize: 18,
                          fontweight: FontWeight.w700,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24.r),
                ],
              ),

              SizedBox(height: 50.h),

              Center(
                child: Obx(() {
                  final progress = controller.progressPercentage;
                  final timeStr = controller.formattedTime;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        // width: 300.r,
                        // height:300.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF22C55E,
                              ).withValues(alpha: 0.05),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 180.r,
                        height: 180.r,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8.r,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF22C55E),
                          ),
                          backgroundColor: const Color(
                            0xFF0F2916,
                          ), // Dark green background track
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Timer Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeStr,
                            style: getTextStyle(
                              fontsize: 30,
                              fontweight: FontWeight.w700,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Time Remaining',
                            style: getTextStyle(
                              fontsize: 12,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),

              SizedBox(height: 50.h),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'You have ${item.timeframe} to review this repost before funds are automatically released.',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontsize: 13,
                      fontweight: FontWeight.w400,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              Text(
                'Order Details',
                style: getTextStyle(
                  fontsize: 14,
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor,
                ),
              ),

              SizedBox(height: 10.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPlatformIcon(item.platform),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repost Option',
                              style: getTextStyle(
                                fontsize: 10,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _getOptionText(item.platform),
                              style: getTextStyle(
                                fontsize: 13,
                                fontweight: FontWeight.w600,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Submitted',
                          style: getTextStyle(
                            fontsize: 12,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(item.createdAt),
                          style: getTextStyle(
                            fontsize: 12,
                            fontweight: FontWeight.w600,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // const Spacer(),

              // // ─── Actions Section ─────────────────────────────────────
              // Text(
              //   'What would you like to do?',
              //   style: getTextStyle(
              //     fontsize: 14,
              //     fontweight: FontWeight.w500,
              //     color: AppColors.primaryTextColor,
              //   ),
              // ),

              // SizedBox(height: 16.h),

              // CustomPrimaryButton(
              //   buttonText: 'Release Funds',
              //   onTap: () => controller.releaseFunds(),
              // ),

              // SizedBox(height: 12.h),

              // OutlinedButton(
              //   onPressed: () => controller.reportIssue(),
              //   style: OutlinedButton.styleFrom(
              //     side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              //     minimumSize: Size(double.infinity, 48.h),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8.r),
              //     ),
              //   ),
              //   child: Text(
              //     'Report an Issue',
              //     style: getTextStyle(
              //       fontsize: 14,
              //       fontweight: FontWeight.w600,
              //       color: const Color(0xFFEF4444),
              //     ),
              //   ),
              // ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  String _getOptionText(String platform) {
    if (platform.toLowerCase() == 'instagram') {
      return 'Instagram Story Repost';
    }
    return '$platform Repost';
  }

  String _getPlatformIconPath(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Iconpath.instagram;
      case 'facebook':
        return Iconpath.facebook;
      case 'tiktok':
        return Iconpath.tiktok;
      case 'youtube':
        return Iconpath.youtube;
      case 'linkedin':
        return Iconpath.linkedIn;
      case 'twitter':
      case 'x':
        return Iconpath.twitter;
      case 'snapchat':
        return Iconpath.snapChat;
      case 'twitch':
        return Iconpath.twitch;
      default:
        return Iconpath.defaultSocial;
    }
  }

  Widget _buildPlatformIcon(String platform) {
    final iconPath = _getPlatformIconPath(platform);
    return Image.asset(
      iconPath,
      height: 28.h,
      width: 28.w,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.share, color: Colors.white, size: 28.r);
      },
    );
  }
}
