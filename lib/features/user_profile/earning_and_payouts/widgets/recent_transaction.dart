import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart'; // Import Iconpath

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TransactionTile(
          platform: 'Instagram',
          amount: 50,
          status: 'Released',
          date: '14 Oct 2025',
        ),
        _TransactionTile(
          platform: 'TikTok',
          amount: 50,
          status: 'Withdrawn',
          date: '12 Oct 2025',
        ),
        _TransactionTile(
          platform: 'YouTube',
          amount: 50,
          status: 'Withdrawn',
          date: '9 Oct 2025',
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String platform;
  final double amount;
  final String status;
  final String date;

  const _TransactionTile({
    required this.platform,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondaryTextColor),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              platform == 'Instagram'
                  ? Image.asset(Iconpath.instagram, height: 24.h, width: 24.w)
                  : platform == 'TikTok'
                  ? Image.asset(Iconpath.tiktok, height: 24.h, width: 24.w)
                  : Image.asset(Iconpath.youtube, height: 24.h, width: 24.w),
              SizedBox(width: 8),
              Text(
                platform,
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 16.sp,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$$amount',
                style: getTextStyle(
                  color: status == 'Withdrawn'
                      ? Colors.amberAccent
                      : AppColors.secondaryTextColor,
                  fontsize: 16.sp,
                ),
              ),
              Text(
                status,
                style: getTextStyle(
                  color: status == 'Released' ? Colors.green : Colors.grey,
                  fontsize: 14.sp,
                ),
              ),
              Text(
                date,
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
