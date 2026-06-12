import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/repost/repost_start/controller/repost_controller.dart';
import 'package:jconnect/features/repost/repost_start/widgets/repost_platform_card.dart';

class RepostPlatformGrid extends StatelessWidget {
  const RepostPlatformGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RepostController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 430;
        final cardWidth = isWide ? 180.w : constraints.maxWidth;

        return Obx(
          () => Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: List.generate(
              controller.platforms.length,
              (index) => SizedBox(
                width: cardWidth,
                child: RepostPlatformCard(
                  platform: controller.platforms[index],
                  onTap: () =>
                      controller.openPlatform(controller.platforms[index]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
