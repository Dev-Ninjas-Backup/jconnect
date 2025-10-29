import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/home/request_service/controller/request_service_controller.dart';

import '../../../../core/common/style/global_text_style.dart';
import '../widgets/customize_your_order.dart';
import '../widgets/request_service_card.dart';

class RequestServiceScreen extends StatelessWidget {
  final RequestServiceController controller = Get.put(
    RequestServiceController(),
  );

  RequestServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "Request Service",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 40.h),

              ReqestServiceCard(),
              SizedBox(height: 40.h),
              Text(
                "Customize Your Order",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 16.h),

              CustomizeYourOrder(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
