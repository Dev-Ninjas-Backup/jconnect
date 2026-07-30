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

  static const _tag = 'search';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<ArtistsController>(tag: _tag, force: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: GetBuilder<ArtistsController>(
          tag: _tag,
          init: ArtistsController(), // isolated instance for SearchScreen only
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 74.h),
              child: SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.searchTextController,
                      builder: (context, value, child) {
                        return CustomTextfield(
                          controller: controller.searchTextController,
                          hintText: "Search artists or influencers…",
                          prefixIcon: Icon(
                            Icons.search,
                            size: sp(20),
                            color: AppColors.secondaryTextColor,
                          ),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: sp(18),
                                    color: AppColors.secondaryTextColor,
                                  ),
                                  onPressed: () {
                                    controller.searchTextController.clear();
                                    controller.searchArtistItems.clear();
                                  },
                                )
                              : null,
                          onChanged: (val) {
                            if (val.trim().isEmpty) {
                              controller.searchArtistItems.clear();
                            } else {
                              controller.searchArtistByName(val);
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 25.h),
                    ArtistsItem(controller: controller, disableFilter: true),
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

