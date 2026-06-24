import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_proof_upload/controller/repost_proof_upload_controller.dart';

class ProofNoteInput extends StatelessWidget {
  final RepostProofUploadController controller;
  const ProofNoteInput({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.noteController,
            maxLines: 4,
            maxLength: 300,
            style: getTextStyle(
              fontsize: 14,
              color: AppColors.primaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: 'Add any additional details...',
              hintStyle: getTextStyle(
                fontsize: 14,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              contentPadding: EdgeInsets.all(16.r),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Obx(() {
                return Text(
                  '${controller.noteText.value.length}/300',
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
    );
  }
}
