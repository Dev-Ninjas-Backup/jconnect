import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/features/home/artists_screen/widgets/artists_item.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.delete<ArtistsController>(force: true);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: GetBuilder<ArtistsController>(
          init: ArtistsController(), // created ONCE
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 74.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CustomTextfield(
                      controller: controller.searchTextController,
                      hintText: "Search artists or influencers…",
                      prefixIcon: Icon(
                        Icons.search,
                        size: sp(20),
                        color: AppColors.secondaryTextColor,
                      ),
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          controller.searchArtistItems.clear();
                        } else {
                          controller.searchArtistByName(value);
                        }
                      },
                    ),
                    SizedBox(height: 40.h),
                    ArtistsItem(controller: controller),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
