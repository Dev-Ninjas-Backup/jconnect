import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/seller_active_order_state/controller/request_details_controller.dart';
import 'package:jconnect/features/repost/repost_proof_upload/screen/repost_proof_upload_screen.dart';

class SellerActiveOrderScreen extends StatelessWidget {
  final RepostStatusItem item;
  const SellerActiveOrderScreen({required this.item, super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      RequestDetailsController(item: item),
      tag: 'accepted',
    );
    final orderCode = item.orderCode;
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                CustomAppBar2(
                  title: "Order #$orderCode",
                  leadingIconUrl: Iconpath.backIcon,
                  onLeadingTap: () => Get.back(),
                ),
                SizedBox(height: 80.h),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() {
                            final currentItem = controller.detailedItem.value ?? item;
                            String statusText = 'Accepted';
                            if (currentItem.status == 'PROOF_SUBMITTED') {
                              statusText = 'Proof Submitted';
                            } else if (currentItem.status == 'REDO_REQUESTED') {
                              statusText = 'Redo Requested';
                            } else if (currentItem.status == 'IN_PROGRESS') {
                              statusText = 'In Progress';
                            } else if (currentItem.status == 'COMPLETED') {
                              statusText = 'Completed';
                            } else if (currentItem.status == 'REFUNDED') {
                              statusText = 'Refunded';
                            } else if (currentItem.status == 'CANCELLED' || currentItem.status == 'REJECTED') {
                              statusText = 'Cancelled';
                            }
                            return Text(
                              statusText,
                              style: getTextStyle(
                                fontsize: 20,
                                fontweight: FontWeight.w700,
                                color: AppColors.primaryTextColor,
                              ),
                            );
                          }),
                          SizedBox(height: 24.h),

                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00C853),
                                width: 2.w,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: const Color(0xFF00C853),
                                size: 24.r,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Text(
                            'Time Remaining',
                            style: getTextStyle(
                              fontsize: 13,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          Obx(() {
                            return Text(
                              controller.formattedTime,
                              style: getTextStyle(
                                fontsize: 36,
                                fontweight: FontWeight.w700,
                                color: const Color(0xFF00C853),
                              ),
                            );
                          }),
                          SizedBox(height: 24.h),

                          Text(
                            'Buyer',
                            style: getTextStyle(
                              fontsize: 13,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() {
                            final currentItem =
                                controller.detailedItem.value ?? item;
                            return Text(
                              '@${currentItem.buyer?.username ?? 'buyer'}',
                              style: getTextStyle(
                                fontsize: 16,
                                fontweight: FontWeight.w600,
                                color: AppColors.primaryTextColor,
                              ),
                            );
                          }),
                          SizedBox(height: 20.h),
                          Text(
                            'Amount',
                            style: getTextStyle(
                              fontsize: 13,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() {
                            final currentItem =
                                controller.detailedItem.value ?? item;
                            return Text(
                              '\$${currentItem.amount.toStringAsFixed(2)}',
                              style: getTextStyle(
                                fontsize: 20,
                                fontweight: FontWeight.w700,
                                color: AppColors.primaryTextColor,
                              ),
                            );
                          }),
                          SizedBox(height: 32.h),
                           Obx(() {
                            final currentItem = controller.detailedItem.value ?? item;
                            final isCompleted = currentItem.status == 'COMPLETED';
                            final isProofSubmitted = currentItem.status == 'PROOF_SUBMITTED';
                            
                            if (isCompleted) {
                              return CustomPrimaryButton(
                                buttonText: 'Completed',
                                gradientColor: [
                                  const Color(0xFF0F2916),
                                  const Color(0xFF22C55E).withValues(alpha: 0.2),
                                  const Color(0xFF0F2916)
                                ],
                                onTap: () => Get.back(),
                              );
                            }
                            
                            return CustomPrimaryButton(
                              buttonText: isProofSubmitted ? 'Proof Submitted' : 'Submit Proof',
                              gradientColor: isProofSubmitted
                                  ? [const Color(0xFF2E2E2E), const Color(0xFF424242), const Color(0xFF2E2E2E)]
                                  : null,
                              onTap: isProofSubmitted
                                  ? () {}
                                  : () => Get.to(
                                        () => RepostProofUploadScreen(
                                          item: currentItem,
                                        ),
                                      ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
