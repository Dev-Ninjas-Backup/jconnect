import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_status/controller/repost_status_controller.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_review_window/screen/repost_review_window_screen.dart';
import 'package:jconnect/features/repost/seller_active_order_state/screen/request_details_screen.dart';

class RepostStatusCard extends StatelessWidget {
  final RepostStatusItem item;
  final bool isPaidTab;

  const RepostStatusCard({
    super.key,
    required this.item,
    required this.isPaidTab,
  });

  Color _statusColor(RepostStatusType status) {
    switch (status) {
      case RepostStatusType.active:
        return Colors.blueAccent;
      case RepostStatusType.completed:
        return Colors.greenAccent;
      case RepostStatusType.cancelled:
        return Colors.redAccent;
    }
  }

  Color _bgColor() =>
      isPaidTab ? const Color(0xFF0D1F2D) : Colors.teal.withValues(alpha: .08);

  Color _borderColor() => isPaidTab
      ? Colors.blueAccent.withValues(alpha: 0.25)
      : Colors.white.withValues(alpha: .5);

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    final controller = Get.find<RepostStatusController>();

    return GestureDetector(
      onTap: (item.status == RepostStatusType.active)
          ? () {
              if (isPaidTab) {
                Get.to(() => RepostReviewWindowScreen(item: item));
              } else {
                Get.to(() => RequestDetailsScreen(item: item));
              }
            }
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _borderColor()),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isPaidTab
                              ? Colors.blueAccent.withValues(alpha: 0.2)
                              : AppColors.redColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          item.platform,
                          style: getTextStyle(
                            fontsize: 10,
                            fontweight: FontWeight.w600,
                            color: isPaidTab
                                ? Colors.blueAccent
                                : AppColors.redColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.timer_outlined,
                        size: 12.r,
                        color: AppColors.secondaryTextColor,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        item.timeframe,
                        style: getTextStyle(
                          fontsize: 11,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Content URL — copyable
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: item.contentUrl));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 14.r,
                            color: AppColors.secondaryTextColor,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              item.contentUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontsize: 11,
                                color: Colors.blueAccent.shade100,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.copy_rounded,
                            size: 13.r,
                            color: AppColors.secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Seller / buyer label
                  Text(
                    isPaidTab
                        ? 'Seller: ${item.sellerName}'
                        : 'Requested by buyer',
                    style: getTextStyle(
                      fontsize: 11,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Status chip + amount
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 7.r, color: statusColor),
                            SizedBox(width: 4.w),
                            Text(
                              controller.statusLabel(item.status),
                              style: getTextStyle(
                                fontsize: 11,
                                fontweight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${item.amount.toStringAsFixed(2)}',
                        style: getTextStyle(
                          fontsize: 14,
                          fontweight: FontWeight.w700,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
