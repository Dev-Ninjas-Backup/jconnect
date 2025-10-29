import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/user_profile/reviews/widget/review_list_widget.dart';
import 'package:jconnect/features/user_profile/reviews/widget/review_widget.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

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
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 26.h),
              ReviewWidget(),
              SizedBox(height: 18),
              Expanded(child: ReviewListWidget()),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {},
                child: Text('Veiw More', style: getTextStyle()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
