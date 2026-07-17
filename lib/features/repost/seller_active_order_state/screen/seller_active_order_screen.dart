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
import 'package:jconnect/features/repost/repost_proof_upload/screen/repost_proof_upload_screen.dart';

class SellerActiveOrderScreen extends StatelessWidget {
  final RepostStatusItem item;
  const SellerActiveOrderScreen({required this.item, super.key});

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'PROOF_SUBMITTED':
        return Colors.blueAccent;
      case 'REDO_REQUESTED':
        return Colors.orangeAccent;
      case 'IN_PROGRESS':
        return const Color(0xFF00C853);
      case 'REFUNDED':
        return Colors.amberAccent;
      case 'REJECTED':
      case 'CANCELLED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle_outline_rounded;
      case 'PROOF_SUBMITTED':
        return Icons.document_scanner_outlined;
      case 'REDO_REQUESTED':
        return Icons.replay_rounded;
      case 'IN_PROGRESS':
        return Icons.play_arrow_rounded;
      case 'REFUNDED':
        return Icons.keyboard_return_rounded;
      case 'REJECTED':
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PROOF_SUBMITTED':
        return 'Proof Submitted';
      case 'REDO_REQUESTED':
        return 'Redo Requested';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'REFUNDED':
        return 'Refunded';
      case 'CANCELLED':
      case 'REJECTED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

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
    final controller = Get.put(
      RequestDetailsController(item: item),
      tag: 'accepted',
    );
    final orderCode = item.orderCode;

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              CustomAppBar2(
                title: "Order #$orderCode",
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
                      // Status Banner
                      Obx(() {
                        final currentItem = controller.detailedItem.value ?? item;
                        final color = _statusColor(currentItem.status);
                        final icon = _statusIcon(currentItem.status);
                        final statusText = _getStatusText(currentItem.status);
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: color.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: 30.r,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      statusText.toUpperCase(),
                                      style: getTextStyle(
                                        fontsize: 18,
                                        fontweight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Updated: ${_formatDate(currentItem.updatedAt)}',
                                      style: getTextStyle(
                                        fontsize: 11,
                                        color: AppColors.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      SizedBox(height: 16.h),

                      // Time Remaining
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
                              'Time Remaining',
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
                                  color: const Color(0xFF00C853),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

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

              // Action button
              Obx(() {
                final currentItem = controller.detailedItem.value ?? item;
                final isCompleted = currentItem.status == 'COMPLETED';
                final isProofSubmitted = currentItem.status == 'PROOF_SUBMITTED';

                if (isCompleted) {
                  return CustomPrimaryButton(
                    buttonText: 'Completed',
                    gradientColor: [
                      const Color(0xFF0F2916),
                      const Color(0xFF22C55E).withValues(alpha: 0.2),
                      const Color(0xFF0F2916)
                    ],
                    onTap: () => Get.back(),
                  );
                }

                return CustomPrimaryButton(
                  buttonText: isProofSubmitted ? 'Proof Submitted' : 'Submit Proof',
                  gradientColor: isProofSubmitted
                      ? [const Color(0xFF2E2E2E), const Color(0xFF424242), const Color(0xFF2E2E2E)]
                      : null,
                  onTap: isProofSubmitted
                      ? () {}
                      : () => Get.to(
                            () => RepostProofUploadScreen(
                              item: currentItem,
                            ),
                          ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

