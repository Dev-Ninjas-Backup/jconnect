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

        return Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(color: Colors.red),
              ),
            );
          }
          if (controller.isError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }
          if (controller.platforms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.repeat, color: Colors.white24, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No active repost options available for this artist',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return Wrap(
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
          );
        });
      },
    );
  }
}
