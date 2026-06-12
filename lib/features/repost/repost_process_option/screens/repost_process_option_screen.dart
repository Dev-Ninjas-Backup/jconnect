import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_process_option/controller/repost_process_option_controller.dart';
import 'package:jconnect/features/repost/repost_process_option/widgets/repost_option_list.dart';
import 'package:jconnect/features/repost/repost_process_option/widgets/repost_platform_header.dart';
import 'package:jconnect/features/repost/repost_process_option/widgets/repost_platform_notes.dart';

class RepostProcessOptionScreen extends GetView<RepostProcessOptionController> {
  const RepostProcessOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Obx(() {
          final platform = controller.platform.value;
          if (platform == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar2(
                  title: 'Select Repost Option',
                  leadingIconUrl: Iconpath.backIcon,
                  onLeadingTap: () => Get.back(),
                ),
                SizedBox(height: 18.h),
                RepostPlatformHeader(platform: platform),
                SizedBox(height: 20.h),
                RepostOptionList(platform: platform),
                SizedBox(height: 16.h),
                const RepostPlatformNotes(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
