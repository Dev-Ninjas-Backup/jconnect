import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/controller/earnings_controller.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/widgets/earning_chart.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/widgets/earning_section.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/widgets/recent_transaction.dart';

class EarningAndPayoutsScreen extends StatelessWidget {
  const EarningAndPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomAppBar2(
                  title: 'Earnings & Payouts',
                  leadingIconUrl: Iconpath.backIcon,
                  onLeadingTap: () => Get.back(),
                ),
                SizedBox(height: 32.h),

                // DYNAMIC CHART SECTION
                GetX<EarningsController>(
                  init: EarningsController(),
                  builder: (controller) {
                    return Container(
                      height: 310.h,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondaryTextColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildChartHeader(),
                          SizedBox(height: 20.h),
                          Expanded(
                            child: controller.monthlyEarnings.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                    ),
                                  )
                                : EarningChart(
                                    data: controller.monthlyEarnings,
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 32.h),
                const EarningsSection(),
                SizedBox(height: 16.h),
                const RecentTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Monthly Earnings',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }
}
