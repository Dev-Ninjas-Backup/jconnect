import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/controller/create_edit_repost_listing_controller.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/widgets/description_field.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/widgets/dollar_program_card.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/widgets/dropdown_field.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/widgets/price_field.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/widgets/section_label.dart';

class CreateEditRepostListingScreen extends StatelessWidget {
  const CreateEditRepostListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CreateEditRepostListingController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      Iconpath.backIcon,
                      height: 36.h,
                      width: 36.w,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Create / Edit Listing',
                        style: getTextStyle(
                          fontsize: 18,
                          fontweight: FontWeight.w600,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Obx(
                  () {
                    if (c.isFetchingDetails.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Platform
                      SectionLabel(label: 'Platform'),
                      SizedBox(height: 8.h),
                      DropdownField<String>(
                        value: c.selectedPlatform.value,
                        items: c.platformApiMap.keys.toList(),
                        onChanged: c.onPlatformChanged,
                      ),
                      SizedBox(height: 20.h),

                      // Price
                      SectionLabel(label: 'Price'),
                      SizedBox(height: 8.h),
                      PriceField(controller: c.priceController),
                      SizedBox(height: 6.h),
                      Text(
                        'Set your price per repost',
                        style: getTextStyle(
                          fontsize: 12,
                          color: Colors.grey,
                          fontweight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 16.h),
                      SectionLabel(label: 'Platform Follower Count'),
                      SizedBox(height: 8.h),
                      PriceField(
                        controller: c.platformFollowerController,
                        priceController: false,
                      ),
                      SizedBox(height: 16.h),

                      // Dollar program toggle
                      DollarProgramCard(
                        isEnabled: c.acceptsDollarProgram.value,
                        onChanged: c.toggleDollarProgram,
                      ),
                      SizedBox(height: 20.h),

                      // Turnaround time
                      SectionLabel(label: 'Turnaround Time (Default)'),
                      SizedBox(height: 8.h),
                      DropdownField<String>(
                        value: c.selectedTurnaround.value,
                        items: c.turnaroundOptions.keys.toList(),
                        onChanged: c.onTurnaroundChanged,
                      ),
                      SizedBox(height: 20.h),

                      // Description
                      SectionLabel(label: 'Description (Optional)'),
                      SizedBox(height: 8.h),
                      DescriptionField(
                        controller: c.descriptionController,
                        currentLength: c.descriptionLength.value,
                        maxLength: CreateEditRepostListingController
                            .maxDescriptionLength,
                      ),
                      SizedBox(height: 20.h),
                      CustomPrimaryButton(buttonText: 'Save', onTap: c.onSave),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
