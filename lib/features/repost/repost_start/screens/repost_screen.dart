import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_start/controller/repost_controller.dart' show RepostController;
import 'package:jconnect/features/repost/repost_start/widgets/repost_platform_grid.dart';

class RepostScreen extends StatelessWidget {
  RepostScreen({super.key});

  final RepostController controller = Get.put(RepostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 18.h),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Repost Hub',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
              SizedBox(height: 20.h),
              RepostPlatformGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
