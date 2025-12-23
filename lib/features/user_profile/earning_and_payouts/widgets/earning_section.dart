import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/controller/earnings_controller.dart';

class EarningsSection extends StatelessWidget {
  const EarningsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<EarningsController>(
      // Ensure the controller is initialized only once
      init: EarningsController(),
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backGroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondaryTextColor),
          ),
          child: Column(
            children: [
              // Added .value to display the number correctly
              _buildRow(
                'Total Earnings',
                '\$${controller.totalEarnings.value}',
              ),
              Divider(color: AppColors.secondaryTextColor),
              _buildRow(
                'Pending Clearance',
                '\$${controller.pendingClearance.value}',
              ),
              Divider(color: AppColors.secondaryTextColor),
              _buildRow(
                'Available to Withdraw',
                '\$${controller.availableToWithdraw.value}',
              ),
              SizedBox(height: 16.h),
              CustomPrimaryButton(
                buttonText: 'Withdraw',
                onTap: () => _showWithdrawPopup(context, controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontsize: 16.sp,
          ),
        ),
        Text(
          value,
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontsize: 16.sp,
          ),
        ),
      ],
    );
  }

  void _showWithdrawPopup(BuildContext context, EarningsController controller) {
    final TextEditingController amountController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.backGroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Withdraw Funds',
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontsize: 18.sp,
                    fontweight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Enter amount',
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.secondaryTextColor,
                  hintText: 'e.g. 150',
                  hintStyle: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.secondaryTextColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.secondaryTextColor),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              CustomPrimaryButton(
                buttonText: 'Withdraw',
                onTap: () {
                  final enteredAmount = int.tryParse(amountController.text);
                  if (enteredAmount == null || enteredAmount <= 0) {
                    Get.snackbar(
                      'Invalid Amount',
                      'Please enter a valid withdrawal amount',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withValues(alpha: .7),
                      colorText: AppColors.primaryTextColor,
                    );
                    return;
                  }

                  controller.processWithdrawal(enteredAmount);
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Withdrawal request submitted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withValues(alpha: .7),
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
