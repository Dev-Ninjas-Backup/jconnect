import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/core/utils/social_link_launcher.dart';

class RepostInactiveOrderDetailsScreen extends StatelessWidget {
  final RepostStatusItem item;
  final bool isPaidTab;

  const RepostInactiveOrderDetailsScreen({
    required this.item,
    required this.isPaidTab,
    super.key,
  });

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'REFUNDED':
        return Colors.orangeAccent;
      case 'REJECTED':
      case 'CANCELLED':
        return Colors.redAccent;
      case 'DISPUTED':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle_outline_rounded;
      case 'REFUNDED':
        return Icons.keyboard_return_rounded;
      case 'REJECTED':
      case 'CANCELLED':
        return Icons.cancel_outlined;
      case 'DISPUTED':
        return Icons.gavel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getPlatformDisplayName(String platform) {
    switch (platform.toUpperCase()) {
      case 'INSTAGRAM_STORY':
        return 'Instagram Story Repost';
      case 'INSTAGRAM_FEED':
      case 'INSTAGRAM_POST':
        return 'Instagram Feed Repost';
      case 'INSTAGRAM_REEL':
        return 'Instagram Reel Repost';
      case 'TIKTOK':
        return 'Tiktok Repost';
      case 'TIKTOK_DUET':
        return 'Tiktok Duet/Stitch Repost';
      case 'TWITTER':
        return 'X Repost';
      case 'TWITTER_QUOTE':
        return 'X Quote Repost';
      case 'YOUTUBE_COMMUNITY_POST':
        return 'YouTube Community Post Repost';
      case 'YOUTUBE_SHORTS':
      case 'YOUTUBE_SHORT':
        return 'YouTube Video Repost (Shorts)';
      case 'FACEBOOK_POST':
        return 'Facebook Post Repost';
      case 'FACEBOOK_STORY':
        return 'Facebook Story Repost';
      default:
        return platform.replaceAll('_', ' ');
    }
  }

  String _getPlatformIcon(String platform) {
    final lower = platform.toLowerCase();
    if (lower.contains('instagram')) {
      return Iconpath.instagram;
    } else if (lower.contains('tiktok')) {
      return Iconpath.tiktok;
    } else if (lower.contains('twitter') || lower.contains('twitter_quote')) {
      return Iconpath.twitter;
    } else if (lower.contains('facebook')) {
      return Iconpath.facebook;
    } else if (lower.contains('youtube')) {
      return Iconpath.youtube;
    }
    return Iconpath.defaultSocial;
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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showGradientSnackBar(
      title: 'Copied',
      message: '$label copied to clipboard!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    final icon = _statusIcon(item.status);

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "Order Details",
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
                      // ─── Status banner ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: color.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                                    item.status.toUpperCase(),
                                    style: getTextStyle(
                                      fontsize: 18,
                                      fontweight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Code: ${item.orderCode}',
                                    style: getTextStyle(
                                      fontsize: 13,
                                      fontweight: FontWeight.w500,
                                      color: AppColors.primaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Updated: ${_formatDate(item.updatedAt)}',
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
                      ),
                      SizedBox(height: 16.h),

                      // ─── Participants section ───────────────────────────
                      isPaidTab
                          ? _buildParticipantCard(
                              title: 'Seller',
                              username: item.seller?.username ?? 'Seller',
                              photoUrl: item.seller?.profilePhoto,
                            )
                          : _buildParticipantCard(
                              title: 'Buyer',
                              username: item.buyer?.username ?? 'Buyer',
                              photoUrl: item.buyer?.profilePhoto,
                            ),
                      SizedBox(height: 16.h),

                      // ─── Platform & Service details ───────────────────────
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
                        child: Row(
                          children: [
                            Image.asset(
                              _getPlatformIcon(item.platform),
                              height: 32.h,
                              width: 32.w,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 32.r,
                                );
                              },
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Platform Option',
                                    style: getTextStyle(
                                      fontsize: 11,
                                      color: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _getPlatformDisplayName(item.platform),
                                    style: getTextStyle(
                                      fontsize: 14,
                                      fontweight: FontWeight.w600,
                                      color: AppColors.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Price',
                                  style: getTextStyle(
                                    fontsize: 11,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '\$${item.amount.toStringAsFixed(2)}',
                                  style: getTextStyle(
                                    fontsize: 15,
                                    fontweight: FontWeight.bold,
                                    color: const Color(0xFFBB0224),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ─── Content to repost ──────────────────────────────
                      _buildHeaderLabel('Content to Repost'),
                      SizedBox(height: 8.h),
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
                              child: GestureDetector(
                                onTap: item.contentUrl.isNotEmpty
                                    ? () => SocialLinkLauncher.launchSocialLink(item.contentUrl)
                                    : null,
                                child: Text(
                                  item.contentUrl.isNotEmpty
                                      ? item.contentUrl
                                      : 'No link provided',
                                  style: getTextStyle(
                                    fontsize: 13,
                                    color: item.contentUrl.isNotEmpty
                                        ? Colors.blueAccent
                                        : AppColors.secondaryTextColor,
                                    fontweight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (item.contentUrl.isNotEmpty) ...[
                              SizedBox(width: 8.w),
                              IconButton(
                                icon: Icon(
                                  Icons.content_copy_rounded,
                                  color: Colors.grey,
                                  size: 20.r,
                                ),
                                onPressed: () => _copyToClipboard(
                                  item.contentUrl,
                                  'Content URL',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ─── Proof of Work section (If COMPLETED) ───────────
                      if (item.status.toUpperCase() == 'COMPLETED') ...[
                        _buildHeaderLabel('Submitted Proof'),
                        SizedBox(height: 8.h),
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
                                  Expanded(
                                    child: (item.proofUrl != null &&
                                            item.proofUrl!.isNotEmpty)
                                        ? Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.proofUrl!,
                                                  style: getTextStyle(
                                                    fontsize: 13,
                                                    color: Colors.greenAccent,
                                                    fontweight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.content_copy_rounded,
                                                  color: Colors.grey,
                                                  size: 18.r,
                                                  key: const ValueKey('proof_url_copy'),
                                                ),
                                                onPressed: () => _copyToClipboard(
                                                  item.proofUrl!,
                                                  'Proof URL',
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Proof of Work',
                                            style: getTextStyle(
                                              fontsize: 13,
                                              fontweight: FontWeight.w600,
                                              color: AppColors.primaryTextColor,
                                            ),
                                          ),
                                  ),
                                  if (item.proofFiles.isNotEmpty) ...[
                                    SizedBox(width: 12.w),
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(
                                          Dialog(
                                            backgroundColor: Colors.black,
                                            insetPadding: EdgeInsets.zero,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: InteractiveViewer(
                                                    minScale: 0.5,
                                                    maxScale: 4.0,
                                                    child: Image.network(
                                                      item.proofFiles.first,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Center(
                                                          child: Icon(
                                                            Icons.image_not_supported_outlined,
                                                            color: Colors.white54,
                                                            size: 48,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 40.h,
                                                  right: 20.w,
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.black54,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => Get.back(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.insert_drive_file_outlined,
                                          color: Color(0xFF22C55E),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (item.proofNote != null &&
                                  item.proofNote!.isNotEmpty) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  'Note:',
                                  style: getTextStyle(
                                    fontsize: 11,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.proofNote!,
                                  style: getTextStyle(
                                    fontsize: 13,
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ],
                              if ((item.proofUrl == null ||
                                      item.proofUrl!.isEmpty) &&
                                  (item.proofNote == null ||
                                      item.proofNote!.isEmpty) &&
                                  item.proofFiles.isEmpty) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  'Proof was uploaded via image/file.',
                                  style: getTextStyle(
                                    fontsize: 13,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // ─── Payment Breakdown ──────────────────────────────
                      _buildHeaderLabel('Payment Breakdown'),
                      SizedBox(height: 8.h),
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
                              'Total Payment',
                              '\$${item.amount.toStringAsFixed(2)}',
                            ),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.06),
                              height: 20.h,
                            ),
                            _buildPaymentRow(
                              'Platform Fee (10%)',
                              '\$${item.platformFee.toStringAsFixed(2)}',
                              isNegative: true,
                            ),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.06),
                              height: 20.h,
                            ),
                            _buildPaymentRow(
                              item.status.toUpperCase() == 'COMPLETED'
                                  ? 'Seller Payout'
                                  : 'Refunded Amount',
                              '\$${item.sellerAmount.toStringAsFixed(2)}',
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                    username.substring(0, 1).toUpperCase(),
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
    return Text(
      text,
      style: getTextStyle(
        fontsize: 14,
        fontweight: FontWeight.w600,
        color: AppColors.primaryTextColor,
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
}
