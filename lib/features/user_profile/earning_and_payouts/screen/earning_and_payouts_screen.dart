import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
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
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomAppBar2(
                  title: 'Earnings & Payouts',
                  leadingIconUrl: Iconpath.backIcon,
                  onLeadingTap: () {
                    Get.back();
                  },
                ),
                SizedBox(height: 32),
                Container(
                  height: 310.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.secondaryTextColor,
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: AssetImage(Imagepath.chart),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                EarningsSection(),
                SizedBox(height: 16),
                RecentTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
