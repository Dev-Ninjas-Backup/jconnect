import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_proof_upload/controller/repost_proof_upload_controller.dart';
import 'package:jconnect/features/repost/repost_proof_upload/widgets/proof_upload_card.dart';
import 'package:jconnect/features/repost/repost_proof_upload/widgets/proof_note_input.dart';

class RepostProofUploadScreen extends StatelessWidget {
  final RepostStatusItem item;
  const RepostProofUploadScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RepostProofUploadController(item: item));

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar2(
                  title: "Submit Proof",
                  onLeadingTap: () => Get.back(),
                  leadingIconUrl: Iconpath.backIcon,
                ),
                SizedBox(height: 24.h),

                Text(
                  "Upload proof that you have reposted the buyer's content.",
                  style: getTextStyle(
                    fontsize: 13,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 32.h),

                Text(
                  'Upload Proof',
                  style: getTextStyle(
                    fontsize: 14,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 10.h),

                ProofUploadCard(controller: controller),
                SizedBox(height: 24.h),

                Text(
                  'Add a note (optional)',
                  style: getTextStyle(
                    fontsize: 14,
                    fontweight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 10.h),

                ProofNoteInput(controller: controller),
                SizedBox(height: 48.h),

                CustomPrimaryButton(
                  buttonText: 'Submit',
                  onTap: () => controller.submitProof(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
