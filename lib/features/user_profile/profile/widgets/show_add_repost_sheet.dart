import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';

void showAddRepostSheet(AddServiceController controller) {
  controller.clearForm();
  controller.selectedServiceType.value = 'REPOST';

  String? selectedPlatform;
  String? selectedPostOption;

  final Map<String, List<String>> platformOptions = {
    'Instagram': ['Story Repost', 'Feed Repost', 'Reel Repost'],
    'Tiktok': ['Repost', 'Duet/Stitch Repost'],
    'X': ['Repost', 'Quote Repost'],
    'YouTube': ['Community Post Repost', 'Video Repost (Shorts)'],
    'Facebook': ['Post Repost', 'Story Repost'],
  };

  final Map<String, String> platformApiMap = {
    'Instagram': 'INSTAGRAM',
    'Tiktok': 'TIKTOK',
    'X': 'TWITTER',
    'YouTube': 'YOUTUBE',
    'Facebook': 'FACEBOOK',
  };

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        final options = selectedPlatform != null
            ? platformOptions[selectedPlatform] ?? []
            : [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sell Repost",
                        style: getTextStyle(
                          fontsize: 18,
                          fontweight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Service Type (Fixed)
                      TextField(
                        controller: TextEditingController(text: "Repost"),
                        readOnly: true,
                        style: getTextStyle(color: AppColors.primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Service Type',
                          labelStyle: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryTextColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryTextColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Platform Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: AppColors.backGroundColor,
                        initialValue: selectedPlatform,
                        decoration: InputDecoration(
                          labelText: 'Platform',
                          labelStyle: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryTextColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.redColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: platformOptions.keys
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p,
                                child: Text(
                                  p,
                                  style: getTextStyle(
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedPlatform = val;
                            selectedPostOption = null;
                            if (val != null) {
                              final apiPlatform = platformApiMap[val];
                              controller.onSocialPlatformChanged(apiPlatform);
                            } else {
                              controller.selectedSocialPlatform.value = null;
                              controller.selectedLogoPath.value = '';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Post Option Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: AppColors.backGroundColor,
                        initialValue: selectedPostOption,
                        disabledHint: Text(
                          "Select a platform first",
                          style: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Post Option',
                          labelStyle: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryTextColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.redColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: options
                            .map(
                              (opt) => DropdownMenuItem<String>(
                                value: opt,
                                child: Text(
                                  opt,
                                  style: getTextStyle(
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: selectedPlatform == null
                            ? null
                            : (val) {
                                setState(() {
                                  selectedPostOption = val;
                                  if (val != null && selectedPlatform != null) {
                                    controller.serviceNameController.text =
                                        "$selectedPlatform $val";
                                  }
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      // Price
                      TextField(
                        controller: controller.priceController,
                        style: getTextStyle(color: AppColors.primaryTextColor),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: getTextStyle(
                            color: AppColors.primaryTextColor,
                          ),
                          labelText: 'Price/promotion',
                          labelStyle: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
                          hintText: "Enter Price",
                          hintStyle: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryTextColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.redColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedPlatform == null) {
                          Get.snackbar('Error', 'Please select a platform.');
                          return;
                        }
                        if (selectedPostOption == null) {
                          Get.snackbar('Error', 'Please select a post option.');
                          return;
                        }
                        await controller.saveService();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
