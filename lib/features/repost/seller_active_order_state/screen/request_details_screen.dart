import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/seller_active_order_state/controller/request_details_controller.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RepostStatusItem item;
  const RequestDetailsScreen({required this.item, super.key});

  Widget _buildParticipantCard({
    required String title,
    required String username,
    String? photoUrl,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFF2C2C2C),
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? Text(
                    username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'B',
                    style: getTextStyle(
                      fontsize: 14,
                      fontweight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getTextStyle(
                    fontsize: 10,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  username,
                  style: getTextStyle(
                    fontsize: 13,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: getTextStyle(
          fontsize: 14,
          fontweight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String amount, {
    bool isNegative = false,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontsize: 12,
            fontweight: isHighlight ? FontWeight.w600 : FontWeight.w400,
            color: isHighlight
                ? AppColors.primaryTextColor
                : AppColors.secondaryTextColor,
          ),
        ),
        Text(
          isNegative ? '-$amount' : amount,
          style: getTextStyle(
            fontsize: isHighlight ? 15 : 13,
            fontweight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight
                ? Colors.greenAccent
                : isNegative
                    ? Colors.redAccent
                    : AppColors.primaryTextColor,
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showGradientSnackBar(
      title: 'Copied',
      message: '$label copied to clipboard!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestDetailsController(item: item));

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "Request #${item.orderCode}",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),

              SizedBox(height: 24.h),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Repost Option
                      Obx(() {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                controller.platformIconPath,
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
                                      fontsize: 12,
                                      color: AppColors.primaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    controller.optionText,
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
                        );
                      }),

                      SizedBox(height: 16.h),

                      // Time to Complete
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Time to Complete',
                              style: getTextStyle(
                                fontsize: 12,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Obx(() {
                              return Text(
                                controller.formattedTime,
                                style: getTextStyle(
                                  fontsize: 36,
                                  fontweight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              );
                            }),
                            SizedBox(height: 6.h),
                            Text(
                              'Time remaining',
                              style: getTextStyle(
                                fontsize: 11,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Buyer Info
                      Obx(() {
                        final currentItem = controller.detailedItem.value ?? item;
                        final buyer = currentItem.buyer;
                        if (buyer == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderLabel('Buyer'),
                            _buildParticipantCard(
                              title: 'Buyer Details',
                              username: buyer.username,
                              photoUrl: buyer.profilePhoto,
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }),

                      // Content to Repost
                      Obx(() {
                        final currentItem = controller.detailedItem.value ?? item;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderLabel('Content to Repost'),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161616),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentItem.contentUrl.isNotEmpty
                                          ? currentItem.contentUrl
                                          : 'No link provided',
                                      style: getTextStyle(
                                        fontsize: 13,
                                        color: currentItem.contentUrl.isNotEmpty
                                            ? Colors.blueAccent
                                            : AppColors.secondaryTextColor,
                                        fontweight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (currentItem.contentUrl.isNotEmpty) ...[
                                    SizedBox(width: 8.w),
                                    IconButton(
                                      icon: Icon(
                                        Icons.content_copy_rounded,
                                        color: Colors.grey,
                                        size: 20.r,
                                      ),
                                      onPressed: () => _copyToClipboard(
                                        currentItem.contentUrl,
                                        'Content URL',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }),

                      // Payment Breakdown
                      Obx(() {
                        final currentItem = controller.detailedItem.value ?? item;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderLabel('Payment Breakdown'),
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
                                children: [
                                  _buildPaymentRow(
                                    'Total Budget',
                                    '\$${currentItem.amount.toStringAsFixed(2)}',
                                  ),
                                  Divider(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    height: 20.h,
                                  ),
                                  _buildPaymentRow(
                                    'Platform Fee (10%)',
                                    '\$${currentItem.platformFee.toStringAsFixed(2)}',
                                    isNegative: true,
                                  ),
                                  Divider(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    height: 20.h,
                                  ),
                                  _buildPaymentRow(
                                    'Your Earnings',
                                    '\$${currentItem.sellerAmount.toStringAsFixed(2)}',
                                    isHighlight: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Action Buttons
              CustomPrimaryButton(
                buttonText: 'Accept Request',
                onTap: () => controller.acceptRequest(),
              ),

              SizedBox(height: 12.h),

              OutlinedButton(
                onPressed: () => controller.rejectRequest(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Reject Request',
                  style: getTextStyle(
                    fontsize: 16,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

