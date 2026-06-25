import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';
import 'package:jconnect/features/repost/create_edit_repost_listing/widgets/dollar_program_card.dart';

void showAddRepostSheet(AddServiceController controller) {
  controller.clearForm();
  controller.selectedServiceType.value = 'REPOST';
  controller.priceController.text = "1.00";

  String? selectedPlatform;
  String? selectedPostOption;
  bool acceptsDollarProgram = true;
  String selectedTurnaround = 'Within 24 Hours';

  final List<String> turnaroundOptions = [
    'Within 30 Minutes',
    'Within 1 Hour',
    'Within 2 Hours',
    'Within 6 Hours',
    'Within 12 Hours',
    'Within 24 Hours',
  ];

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
                          labelText: 'Repost Type',
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
                        readOnly: acceptsDollarProgram,
                        style: getTextStyle(color: AppColors.primaryTextColor),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: getTextStyle(
                            color: AppColors.primaryTextColor,
                          ),
                          labelText: 'Price',
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
                              color: acceptsDollarProgram ? AppColors.secondaryTextColor : AppColors.redColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Accepts $1 Repost Program
                      DollarProgramCard(
                        isEnabled: acceptsDollarProgram,
                        onChanged: (val) {
                          setState(() {
                            acceptsDollarProgram = val;
                            if (val) {
                              controller.priceController.text = "1.00";
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Turnaround Time
                      DropdownButtonFormField<String>(
                        dropdownColor: AppColors.backGroundColor,
                        initialValue: selectedTurnaround,
                        decoration: InputDecoration(
                          labelText: 'Turnaround Time (Default)',
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
                        items: turnaroundOptions
                            .map(
                              (t) => DropdownMenuItem<String>(
                                value: t,
                                child: Text(
                                  t,
                                  style: getTextStyle(
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            if (val != null) {
                              selectedTurnaround = val;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description (Optional)
                      TextField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        maxLength: 200,
                        style: getTextStyle(color: AppColors.primaryTextColor),
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$currentLength/$maxLength',
                              style: getTextStyle(
                                color: AppColors.secondaryTextColor,
                                fontsize: 12,
                              ),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'What buyers can expect...',
                          hintStyle: getTextStyle(
                            color: AppColors.secondaryTextColor,
                          ),
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
                      onPressed: (selectedPlatform == null || selectedPostOption == null)
                          ? null
                          : () async {
                              await controller.saveService();
                              Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (selectedPlatform == null || selectedPostOption == null)
                            ? Colors.grey
                            : AppColors.redColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
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
