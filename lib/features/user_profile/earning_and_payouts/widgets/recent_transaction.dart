import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart'; // Import Iconpath
import 'package:get/get.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/controller/earnings_controller.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<EarningsController>(
      init: EarningsController(),
      builder: (controller) {
        final list = controller.withdrawalHistory;
        if (list.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 8.h),
              Text(
                'No withdrawals yet',
                style: getTextStyle(color: AppColors.secondaryTextColor),
              ),
            ],
          );
        }

        return Column(
          children: List.generate(list.length, (index) {
            final item = list[index];
            final amountNum = (item['amount'] is num)
                ? (item['amount'] as num).toDouble()
                : double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
            final createdAt = item['createdAt']?.toString() ?? '';

            return _TransactionTile(amount: amountNum, date: createdAt);
          }).toList(),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final double amount;
  final String date;

  const _TransactionTile({required this.amount, required this.date});

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
          Text(
            date,
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontsize: 12.sp,
            ),
          ),
          Text(
            '\$${(amount / 100).toStringAsFixed(2)}',
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontsize: 16.sp,
              fontweight: FontWeight.w600,
            ),
          ),

          // Date on the right
        ],
      ),
    );
  }
}
