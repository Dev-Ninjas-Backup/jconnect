import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/features/home/request_service/controller/request_service_controller.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../widgets/customize_your_order.dart';
import '../widgets/request_service_card.dart';

class RequestServiceScreen extends StatelessWidget {
  final RequestServiceController controller = Get.put(
    RequestServiceController(),
  );
  RequestServiceScreen({super.key});

  final service = Get.arguments;
  // final ServiceModel service = Get.arguments as ServiceModel;

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
              ReqestServiceCard(service: service),
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
              SizedBox(height: 40.h),

              // RequestCustomServiceCard(),

              //   SizedBox(height: 40.h),
              // Text(
              //   "Payment Summary",
              //   style: getTextStyle(
              //     fontsize: sp(16),
              //     fontweight: FontWeight.w600,
              //     color: AppColors.primaryTextColor.withValues(alpha: 0.7),
              //   ),
              // ),

              // SizedBox(height: 16.h),

              // GradientBorderContainer(
              //   borderRadius: 6.r,
              //   borderWidth: .6,
              //   padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       //1st row
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Service Price",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //           Text(
              //             "\$150.00",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w500,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 12.h),
              //       //2nd row
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Platform Fee (10%)",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //           Text(
              //             "\$7.00",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 12.h),
              //       Divider(thickness: .6),
              //       SizedBox(height: 6),

              //       //total row
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Total",
              //             style: getTextStyle(
              //               fontsize: sp(16),
              //               fontweight: FontWeight.w600,
              //               color: AppColors.primaryTextColor,
              //             ),
              //           ),

              //           Text(
              //             "\$157.00",
              //             style: getTextStyle(
              //               fontsize: sp(16),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 16.h),

              //       GradientBorderContainer(
              //         color: Color(0xFF353434),

              //         borderRadius: 4.r,
              //         borderWidth: .6,
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 10.w,
              //           vertical: 10.h,
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           spacing: 10.w,
              //           children: [
              //             Image.asset(
              //               Iconpath.securityIcon,
              //               height: 20.h,
              //               width: 20.w,
              //             ),

              //             Expanded(
              //               child: Text(
              //                 "Payment is securely held until both parties confirm completion",
              //                 overflow: TextOverflow.ellipsis,
              //                 maxLines: 2,
              //                 style: getTextStyle(
              //                   fontsize: sp(12),
              //                   color: AppColors.primaryTextColor.withValues(
              //                     alpha: .7,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       SizedBox(height: 12.h),

              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Image.asset(
              //             Iconpath.stripeIcon,
              //             height: 8.h,
              //             width: 18.w,
              //             color: AppColors.primaryTextColor,
              //           ),
              //           SizedBox(width: 8.w),
              //           Text(
              //             "Secured by Stripe",
              //             style: getTextStyle(
              //               fontsize: sp(10),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 40.h),
              CustomPrimaryButton(
                buttonText: "Send Request",
                onTap: () {
                  //  Get.toNamed(AppRoute.getConfirmYourPromotion());

                  controller.submitServiceRequest(
                    serviceId: service.id,
                    price: service.price.toDouble(),
                  );
                },
              ),
              SizedBox(height: 16.h),
              Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomSecondaryButton(
                      buttonText: "Cancel",
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: CustomSecondaryButton(
                      buttonText: "Message Seller",
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Text(
                "Your payment is protected until the service is completed. DJ Connect ensures both sides confirm delivery before funds are released.",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontsize: sp(10),
                  color: AppColors.primaryTextColor.withValues(alpha: .4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
