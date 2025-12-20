import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/user_profile/reviews/controller/review_controller.dart';
import 'package:jconnect/features/user_profile/reviews/widget/review_list_widget.dart';
import 'package:jconnect/features/user_profile/reviews/widget/review_widget.dart';

class ReviewScreen extends StatelessWidget {
  ReviewScreen({super.key});

  final ReviewController controller = Get.put(ReviewController());

  // Observable for controlling view more
  final RxInt displayCount = 5.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Reviews',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
              SizedBox(height: 26.h),
              ReviewWidget(),
              SizedBox(height: 18),
              // Use Obx to rebuild when displayCount changes
              Expanded(
                child: Obx(() {
                  final currentReviews = controller.reviews
                      .take(displayCount.value)
                      .toList();
                  return ReviewListWidget(reviews: currentReviews);
                }),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                // Show button only if more reviews are available
                if (controller.reviews.length > displayCount.value) {
                  return TextButton(
                    onPressed: () {
                      displayCount.value = controller.reviews.length;
                    },
                    child: Text('View More', style: getTextStyle()),
                  );
                } else {
                  return const SizedBox(); // hide button if all reviews are shown
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
