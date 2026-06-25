import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home/home_screen/widgets/spotlight_card.dart';

class AllSpotlightScreen extends StatelessWidget {
  const AllSpotlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: CustomAppBar2(
                title: "Spotlight Users",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  if (controller.isSpotlightLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    );
                  }

                  if (controller.spotlightList.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Spotlight Users Found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  int rowCount = (controller.spotlightList.length / 3).ceil();
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    itemCount: rowCount,
                    itemBuilder: (context, rowIndex) {
                      int startIndex = rowIndex * 3;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(3, (index) {
                            int itemIndex = startIndex + index;
                            if (itemIndex < controller.spotlightList.length) {
                              final item = controller.spotlightList[itemIndex];
                              return Expanded(
                                child: SpotlightCard(
                                  item: item,
                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                ),
                              );
                            } else {
                              return const Expanded(
                                child: SizedBox(),
                              );
                            }
                          }),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
