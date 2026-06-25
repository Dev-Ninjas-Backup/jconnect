import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/buyer_review_post/controller/buyer_review_post_controller.dart';
import 'package:jconnect/features/repost/buyer_review_post/widgets/reject_confirm_dialog.dart';
import 'package:jconnect/features/repost/buyer_review_post/widgets/redo_request_dialog.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';

class BuyerReviewPostScreen extends StatelessWidget {
  final RepostStatusItem item;
  const BuyerReviewPostScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BuyerReviewPostController(item: item));

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar2(
                  title: 'Review Proof',
                  onLeadingTap: () => Get.back(),
                  leadingIconUrl: Iconpath.backIcon,
                ),
                SizedBox(height: 24.h),

                Text(
                  'Seller Submission',
                  style: getTextStyle(
                    fontsize: 16,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Submitted ${DateFormat('hh:mm a').format(controller.reviewModel.submittedAt)}',
                  style: getTextStyle(
                    fontsize: 13,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 18.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          children: [
                            Image.network(
                              controller.reviewModel.proofImageUrl,
                              height: 320.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 320.h,
                                      color: Colors.black26,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF22C55E),
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 320.h,
                                  color: Colors.black26,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white54,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () {
                          // Show Full Size Dialog with pinch to zoom
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.black,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  Center(
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: Image.network(
                                        controller.reviewModel.proofImageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40.h,
                                    right: 20.w,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Get.back(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          alignment: Alignment.center,
                          child: Text(
                            'View Full Size',
                            style: getTextStyle(
                              fontsize: 14,
                              fontweight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),

                Text(
                  'What would you like to do?',
                  style: getTextStyle(
                    fontsize: 15,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 16.h),

                CustomPrimaryButton(
                  buttonText: "Accept & Release Funds",
                  gradientColor: [
                    Color(0xFF1E823E),
                    Color(0xFF28A745),
                    Color.fromARGB(255, 5, 197, 50),
                  ],
                  onTap: () {
                    controller.acceptAndReleaseFunds();
                  },
                ),
                SizedBox(height: 12.h),
                CustomPrimaryButton(
                  buttonText: "Reject",
                  onTap: () {
                    Get.dialog(
                      RejectConfirmDialog(
                        onConfirm: () => controller.processRejection(),
                      ),
                    );
                  },
                ),

           
                SizedBox(height: 12.h),

                OutlinedButton(
                  onPressed: () {
                    Get.dialog(
                      RedoRequestDialog(
                        controller: controller,
                        onSubmit: (instructions) =>
                            controller.submitRedoRequest(instructions),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    minimumSize: Size(double.infinity, 44.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Ask for Redo',
                    style: getTextStyle(
                      fontsize: 16,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
