import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/features/home/artists_screen/widgets/artists_item.dart';
import '../widgets/artists_item_list_tab.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ArtistsController());
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: Column(
          children: [
            CustomAppBar2(
              title: "Artists",
              actionIconUrl: Iconpath.notificationIcon,
              actionOnTap: () {},
              leadingIconUrl: Iconpath.backIcon,
              onLeadingTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 30.h),
            CustomTextfield(
              controller: controller.searchTextController,
              hintText: "Search artists or influencers…",
              prefixIcon: Icon(
                Icons.search,
                size: sp(20),
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 30.h),
            ArtistsItemListTab(controller: controller),
            SizedBox(height: 40.h),
            ArtistsItem(controller: controller),
          ],
        ),
      ),
    );
  }
}
