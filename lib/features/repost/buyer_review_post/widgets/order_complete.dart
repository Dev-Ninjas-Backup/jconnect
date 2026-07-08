import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';

class OrderComplete extends StatelessWidget {
  final RepostStatusItem item;
  final VoidCallback? onViewOrderTap;

  const OrderComplete({required this.item, this.onViewOrderTap, super.key});

  String get _optionText {
    return '${item.platform} Repost';
  }

  String get _platformIconPath {
    final platform = item.platform.toLowerCase();
    if (platform.contains('instagram')) return Iconpath.instagram;
    if (platform.contains('facebook')) return Iconpath.facebook;
    if (platform.contains('tiktok')) return Iconpath.tiktok;
    if (platform.contains('youtube')) return Iconpath.youtube;
    if (platform.contains('linkedin')) return Iconpath.linkedIn;
    if (platform.contains('twitter') || platform == 'x') return Iconpath.twitter;
    if (platform.contains('snapchat')) return Iconpath.snapChat;
    if (platform.contains('twitch')) return Iconpath.twitch;
    return Iconpath.defaultSocial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar2(
                onLeadingTap: () => Get.back(),
                leadingIconUrl: Iconpath.backIcon,
                title: "Order Completed",
              ),
              const Spacer(flex: 1),

              // Green Circular Checkmark
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF22C55E),
                    width: 3.r,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF22C55E),
                    size: 54.r,
                  ),
                ),
              ),
              SizedBox(height: 28.h),

              // Title "Funds Released!"
              Text(
                'Funds Released!',
                style: getTextStyle(
                  fontsize: 24,
                  fontweight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 12.h),

              // Descriptio
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'The buyer did not take action. Funds have been successfully released to the seller.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontsize: 14,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
              const Spacer(flex: 1),

              // Order Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Details',
                          style: getTextStyle(
                            fontsize: 16,
                            fontweight: FontWeight.w600,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        Align(
                          alignment: AlignmentGeometry.topEnd,
                          child: Text(
                            "\$${item.amount.toStringAsFixed(2)}",
                            style: getTextStyle(
                              fontsize: 16,
                              fontweight: FontWeight.w700,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: AlignmentGeometry.topEnd,
                      child: Text(
                        "Order ID: #${item.orderCode}",
                        style: getTextStyle(
                          fontsize: 12,
                          fontweight: FontWeight.w400,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Image.asset(
                          _platformIconPath,
                          height: 28.h,
                          width: 28.w,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 28.r,
                            );
                          },
                        ),
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
                              _optionText,
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
                          DateFormat('hh:mm a').format(item.proofSubmittedAt ?? item.createdAt),
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
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
