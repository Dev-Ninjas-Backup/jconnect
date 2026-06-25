import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/buyer_review_post/controller/buyer_review_post_controller.dart';

class RedoRequestDialog extends StatelessWidget {
  final BuyerReviewPostController controller;
  final Function(String) onSubmit;

  const RedoRequestDialog({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Redo',
              style: getTextStyle(
                fontsize: 18,
                fontweight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide clear instructions on what needs to be changed.',
              style: getTextStyle(fontsize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C0A0A),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller.redoController,
                    maxLines: 4,
                    maxLength: 300,
                    style: getTextStyle(
                      fontsize: 14,
                      color: AppColors.primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Clear Instructions .....',
                      hintStyle: getTextStyle(
                        fontsize: 13,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      contentPadding: EdgeInsets.all(12.r),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12.w, bottom: 8.h),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Obx(() {
                        return Text(
                          '${controller.redoText.value.length}/300',
                          style: getTextStyle(
                            fontsize: 11,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: getTextStyle(
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFBD001F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (controller.redoController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Warning',
                          'Please provide redo instructions.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.amber,
                          colorText: Colors.black,
                        );
                        return;
                      }
                      Get.back(); // Close dialog
                      onSubmit(controller.redoController.text);
                    },
                    child: Text(
                      'Submit',
                      style: getTextStyle(
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
