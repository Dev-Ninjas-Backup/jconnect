import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';
import 'package:jconnect/features/add_services/widget/service_form_widget.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_activity_section.dart';
//import 'package:jconnect/features/user_profile/profile/widgets/profile_rate_section.dart';
import 'package:jconnect/features/user_profile/profile/widgets/profile_settings_section.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final SharedPreferencesHelperController pref = Get.put(
    SharedPreferencesHelperController(),
  );

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                // SizedBox(height: 20),
                // GestureDetector(
                //   onTap: () {
                //     Get.toNamed(AppRoute.addServiceScreen);
                //   },
                //   child: Container(
                //     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         width: 1,
                //         color: AppColors.secondaryTextColor,
                //       ),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Text(
                //       'Add New Service',
                //       style: getTextStyle(
                //         color: Colors.white,
                //         fontsize: 16,
                //         fontweight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                //ProfileRateSection(controller: controller),
                SizedBox(height: 20),
                ProfileActivitySection(controller: controller),
                SizedBox(height: 20),
                ProfileSettingsSection(controller: controller),
                SizedBox(height: 18.h),
                GestureDetector(
                  onTap: () async {
                    // Call controller's delete account flow which performs API DELETE,
                    // clears local data and navigates to login on success.
                    await controller.deleteAccountAsync();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_forever,
                        size: 24,
                        color: AppColors.redColor,
                      ),
                      SizedBox(width: 8),

                      Text(
                        'Delete Account',
                        style: getTextStyle(
                          fontsize: 16,
                          color: AppColors.redColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          // Show network image if the profile image is a URL, otherwise fall back to local asset
          CircleAvatar(
            radius: 45,
            backgroundImage: user.imageUrl.startsWith('http')
                ? NetworkImage(user.imageUrl) as ImageProvider
                : AssetImage(user.imageUrl) as ImageProvider,
          ),
          SizedBox(height: 10),
          Text(
            user.username,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 20,
              fontweight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),
          Text(
            user.email.toString(),
            textAlign: TextAlign.center,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            user.shortbio,
            textAlign: TextAlign.center,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 16,
            ),
          ),

          SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomPrimaryButton(
                  buttonText: "Sell Social Post",
                  fontSize: sp(12),
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    _showAddServiceSheet(addServiceController);
                  },
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: CustomPrimaryButton(
                  buttonText: "Sell Services",
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    _showAddServiceSheet(addServiceController);
                  },
                  fontSize: sp(12),
                ),
              ),
            ],
          ),

          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('${user.totaldeals}', 'Total Deals'),
              _buildStat('\$${user.earnings.toStringAsFixed(2)}', 'Earnings'),
              _buildStat(user.rating.toStringAsFixed(2), 'Rating'),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStat(String value, String label) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.backGroundColor,
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: getTextStyle(
                color: Colors.white,
                fontsize: 20,
                fontweight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: getTextStyle(
                color: AppColors.secondaryTextColor,
                fontsize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddServiceSheet(
  // BuildContext context,
  AddServiceController controller,
) {
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
            children: [
              ServiceFormWidget(
                controller,
                // onChanged: (_) => checkFields()
              ),
              const SizedBox(height: 16),
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
                      onPressed:
                          //  controller.isSaveEnabled.value
                          () async {
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
              SizedBox(height: 35),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
