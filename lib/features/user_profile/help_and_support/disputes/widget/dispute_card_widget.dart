import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import '../model/dispute_model.dart';

class DisputeCardWidget extends StatelessWidget {
  final DisputeModel dispute;

  const DisputeCardWidget({super.key, required this.dispute});

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UNDER_REVIEW':
        return Colors.amber;
      case 'RESOLVED':
        return Colors.green;
      case 'PENDING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      DateTime dt;
      if (raw.toLowerCase() == 'today' || raw.toLowerCase() == 'just now') {
        dt = DateTime.now();
      } else if (RegExp(r'^\d+$').hasMatch(raw)) {
        dt = DateTime.fromMillisecondsSinceEpoch(int.parse(raw)).toLocal();
      } else {
        dt = DateTime.parse(raw).toLocal();
      }
      return DateFormat('MMM d, yyyy · h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatUserName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'Unknown') return trimmed;
    if (trimmed.startsWith('@')) return trimmed;
    return '@$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _formatUserName(dispute.userName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontweight: FontWeight.w600,
                    fontsize: 14,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _formatDate(dispute.date),
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            dispute.dealTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontweight: FontWeight.w500,
              fontsize: 13,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '"${dispute.description}"',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 12,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Amount: \$${(dispute.amount / 100).toStringAsFixed(2)}',
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontweight: FontWeight.w600,
              fontsize: 13,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: getStatusColor(dispute.status),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                dispute.status.replaceAll('_', ' '),
                style: getTextStyle(
                  color: getStatusColor(dispute.status),
                  fontweight: FontWeight.w500,
                  fontsize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
