import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';

class OrderEscrowDeadlineBanner extends StatefulWidget {
  final OrderDetailsModel order;
  final bool isBuyer;
  final bool hasOpenDispute;
  final VoidCallback? onExpired;

  const OrderEscrowDeadlineBanner({
    super.key,
    required this.order,
    required this.isBuyer,
    this.hasOpenDispute = false,
    this.onExpired,
  });

  @override
  State<OrderEscrowDeadlineBanner> createState() =>
      _OrderEscrowDeadlineBannerState();
}

class _OrderEscrowDeadlineBannerState extends State<OrderEscrowDeadlineBanner> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _hasFiredExpired = false;

  @override
  void initState() {
    super.initState();
    _initDeadline();
  }

  @override
  void didUpdateWidget(covariant OrderEscrowDeadlineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.status != widget.order.status ||
        oldWidget.order.acceptDeadline != widget.order.acceptDeadline ||
        oldWidget.order.proofReviewDeadline !=
            widget.order.proofReviewDeadline ||
        oldWidget.order.isCancelRequested != widget.order.isCancelRequested ||
        oldWidget.hasOpenDispute != widget.hasOpenDispute) {
      _initDeadline();
    }
  }

  void _initDeadline() {
    _timer?.cancel();
    _hasFiredExpired = false;

    final targetDeadline = _getTargetDeadline();
    if (targetDeadline == null) {
      setState(() {
        _remainingSeconds = 0;
      });
      return;
    }

    final diff = targetDeadline.difference(DateTime.now());
    _remainingSeconds = diff.inSeconds;

    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final currentDiff = targetDeadline.difference(DateTime.now());
        final secs = currentDiff.inSeconds;

        if (secs <= 0) {
          setState(() {
            _remainingSeconds = 0;
          });
          timer.cancel();
          if (!_hasFiredExpired) {
            _hasFiredExpired = true;
            widget.onExpired?.call();
          }
        } else {
          setState(() {
            _remainingSeconds = secs;
          });
        }
      });
    } else {
      if (!_hasFiredExpired) {
        _hasFiredExpired = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onExpired?.call();
        });
      }
    }
  }

  DateTime? _getTargetDeadline() {
    final status = widget.order.status.toUpperCase().trim();
    if (status == 'PENDING') {
      return widget.order.acceptDeadlineDateTime;
    } else if (status == 'PROOF_SUBMITTED') {
      return widget.order.proofReviewDeadlineDateTime;
    }
    return null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRemainingTime(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    return '$hStr:$mStr:$sStr';
  }

  String _formatVerboseTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status.toUpperCase().trim();
    final isPending =
        status == 'PENDING' &&
        widget.order.acceptDeadline != null &&
        widget.order.acceptDeadline!.isNotEmpty;
    final isProofSubmitted =
        status == 'PROOF_SUBMITTED' &&
        widget.order.proofReviewDeadline != null &&
        widget.order.proofReviewDeadline!.isNotEmpty;

    // Outside active countdown windows
    if (!isPending && !isProofSubmitted) {
      return const SizedBox.shrink();
    }

    final isGuarded = (widget.order.isCancelRequested || widget.hasOpenDispute);

    // ─── 1. GUARDED STATE FOR PROOF SUBMITTED ─────────────────────────────
    if (isProofSubmitted && isGuarded) {
      return Container(
        margin: EdgeInsets.only(bottom: 18.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E170A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pause_circle_filled_rounded,
                color: const Color(0xFFF59E0B),
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Release Paused — Under Review',
                          style: getTextStyle(
                            color: const Color(0xFFF59E0B),
                            fontweight: FontWeight.w600,
                            fontsize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'PAUSED',
                          style: getTextStyle(
                            color: const Color(0xFFF59E0B),
                            fontweight: FontWeight.bold,
                            fontsize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.hasOpenDispute
                        ? 'An issue report is under review by support. Automatic fund release is paused until the dispute is resolved.'
                        : 'A cancellation request is pending seller response. Automatic fund release is paused.',
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontsize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ─── 2. ACTIVE DEADLINE COUNTDOWNS ────────────────────────────────────
    final bool isAccept = isPending;
    final Color primaryAccent = isAccept
        ? const Color(0xFFF59E0B) // Amber for Seller Acceptance
        : (widget.isBuyer
              ? const Color(0xFF3B82F6) // Blue for Buyer Review
              : const Color(0xFF10B981)); // Emerald for Seller Auto-Release

    final Color cardBg = isAccept
        ? const Color(0xFF1C150A)
        : (widget.isBuyer ? const Color(0xFF0D1829) : const Color(0xFF091C14));

    final IconData icon = isAccept
        ? Icons.hourglass_top_rounded
        : (widget.isBuyer
              ? Icons.verified_user_outlined
              : Icons.payments_outlined);

    String title;
    String subtitle;
    String badgeLabel;

    if (isAccept) {
      if (widget.isBuyer) {
        title = 'Waiting for Seller Acceptance';
        subtitle = _remainingSeconds > 0
            ? 'Expires in ${_formatVerboseTime(_remainingSeconds)}. If not accepted, the order is automatically cancelled and your payment is refunded.'
            : 'Acceptance window expired. Awaiting server auto-cancellation & refund...';
        badgeLabel = 'ACCEPTANCE WINDOW';
      } else {
        title = 'Action Required: Accept Order';
        subtitle = _remainingSeconds > 0
            ? 'Accept within ${_formatVerboseTime(_remainingSeconds)} or this order will automatically expire and be refunded to the buyer.'
            : 'Acceptance window expired. Processing auto-cancellation...';
        badgeLabel = 'EXPIRES SOON';
      }
    } else {
      // PROOF_SUBMITTED (Un-guarded)
      if (widget.isBuyer) {
        title = 'Review Submitted Proof';
        subtitle = _remainingSeconds > 0
            ? 'Review within ${_formatVerboseTime(_remainingSeconds)} or funds will be automatically released to the creator.'
            : 'Review window expired. Awaiting automatic fund release...';
        badgeLabel = '24H REVIEW WINDOW';
      } else {
        title = 'Proof Submitted — Awaiting Review';
        subtitle = _remainingSeconds > 0
            ? 'Funds will be automatically released to your balance in ${_formatVerboseTime(_remainingSeconds)} if unreviewed.'
            : 'Review window expired. Processing automatic fund release...';
        badgeLabel = 'AUTO-RELEASE';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primaryAccent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryAccent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryAccent, size: 20.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontweight: FontWeight.w600,
                    fontsize: 14,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  badgeLabel,
                  style: getTextStyle(
                    color: primaryAccent,
                    fontweight: FontWeight.bold,
                    fontsize: 9,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Digital Timer Pill
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: primaryAccent,
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _remainingSeconds > 0 ? 'Time Remaining:' : 'Status:',
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontsize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  _remainingSeconds > 0
                      ? _formatRemainingTime(_remainingSeconds)
                      : 'Expired (Updating...)',
                  style: getTextStyle(
                    color: primaryAccent,
                    fontweight: FontWeight.w700,
                    fontsize: 15,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: getTextStyle(color: const Color(0xFF94A3B8), fontsize: 11.5),
          ),
        ],
      ),
    );
  }
}
