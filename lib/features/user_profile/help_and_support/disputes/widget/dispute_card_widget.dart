import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dispute.userName, style: getTextStyle()),
              Text(dispute.date, style: getTextStyle()),
            ],
          ),
          SizedBox(height: 6.h),
          Text(dispute.dealTitle, style: getTextStyle()),
          SizedBox(height: 6.h),
          Text('"${dispute.description}"', style: getTextStyle()),
          SizedBox(height: 6.h),
          Text('Amount: \$${dispute.amount}', style: getTextStyle()),
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
              Text(dispute.status, style: getTextStyle()),
            ],
          ),
        ],
      ),
    );
  }
}
