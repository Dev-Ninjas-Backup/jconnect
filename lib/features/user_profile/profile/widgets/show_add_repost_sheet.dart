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
  controller.repostPrice.text = "1";
  controller.isSpotlight.value = true;
  controller.selectedTurnaround.value = 'TWENTY_FOUR_HOURS';
  String? selectedPlatform;
  String selectedTurnaround = 'TWENTY_FOUR_HOURS';

  final Map<String, String> turnaroundOptions = {
    'Within 20 Minutes': "TWENTY_MINUTES",
    'Within 1 Hour': "ONE_HOUR",
    'Within 2 Hours': "TWO_HOURS",
    'Within 6 Hours': "SIX_HOURS",
    'Within 12 Hours': "TWELVE_HOURS",
    'Within 24 Hours': "TWENTY_FOUR_HOURS",
  };

  final Map<String, String> platformApiMap = {
    'Instagram Story Repost': 'INSTAGRAM_STORY',
    'Instagram Feed Repost': 'INSTAGRAM_FEED',
    'Instagram Reel Repost': 'INSTAGRAM_REEL',
    'Tiktok Repost': 'TIKTOK',
    'Tiktok Duet/Stitch Repost': 'TIKTOK_DUET',
    'X Repost': 'TWITTER',
    'X Quote Repost': 'TWITTER_QUOTE',
    'YouTube Community Post Repost': 'YOUTUBE_COMMUNITY_POST',
    'YouTube Video Repost (Shorts)': 'YOUTUBE_SHORTS',
    'Facebook Post Repost': 'FACEBOOK_POST',
    'Facebook Story Repost': 'FACEBOOK_STORY',
  };

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
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
                        items: platformApiMap.keys
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
                            if (val != null) {
                              controller.serviceNameController.text = val;
                              final apiPlatform = platformApiMap[val];
                              controller.onSocialPlatformChanged(apiPlatform);
                            } else {
                              controller.serviceNameController.clear();
                              controller.selectedSocialPlatform.value = null;
                              controller.selectedLogoPath.value = '';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Price
                      TextField(
                        controller: controller.repostPrice,
                        style: getTextStyle(color: AppColors.primaryTextColor),
                        readOnly: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
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
                            borderSide: BorderSide(color: AppColors.redColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: controller.followerCountController,
                        style: getTextStyle(color: AppColors.primaryTextColor),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Platform Follower Count',
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
                      const SizedBox(height: 16),

                      // Accepts $1 Repost Program
                      DollarProgramCard(
                        isEnabled: controller.isSpotlight.value ?? true,
                        onChanged: (val) {
                          setState(() {
                            controller.isSpotlight.value = val;
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
                        items: turnaroundOptions.entries
                            .map(
                              (entry) => DropdownMenuItem<String>(
                                value: entry.value,
                                child: Text(
                                  entry.key,
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
                              controller.selectedTurnaround.value = val;
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
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) {
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
                      onPressed: (selectedPlatform == null)
                          ? null
                          : () async {
                              controller.selectedServiceType.value = "REPOST";
                              final success = await controller.saveRepost();
                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  'Success',
                                  'Repost listing saved successfully!',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (selectedPlatform == null)
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
