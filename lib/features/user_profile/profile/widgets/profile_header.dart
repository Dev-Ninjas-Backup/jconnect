import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button_2.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/user_profile/profile/widgets/show_add_repost_sheet.dart';
import 'package:jconnect/features/user_profile/profile/widgets/show_add_service_sheet.dart';
import 'package:jconnect/features/user_profile/profile/widgets/stat_card.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.controller,
  });

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          SizedBox(height: 10.h),
          // Profile image with white circle background
          Container(
            width: 100.w,
            height: 100.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: CircleAvatar(
                radius: 47.w,
                backgroundImage: user.imageUrl.startsWith('http')
                    ? NetworkImage(user.imageUrl) as ImageProvider
                    : AssetImage(user.imageUrl) as ImageProvider,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Username
          Text(
            user.username,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 20,
              fontweight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          // Short bio
          Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            user.shortbio,
            textAlign: TextAlign.center,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 14,
            ),
          ),
          SizedBox(height: 20.h),

          // Three sell buttons row
          Row(
            children: [
              Expanded(
                child: CustomPrimaryButton2(
                  buttonText: "Sell Social Post",
                  fontSize: sp(11),
                  buttonHeight: 40,
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    addServiceController.clearForm();
                    addServiceController.selectedServiceType.value = 'SOCIAL_POST';
                    addServiceController.isSocialService.value = true;
                    showAddServiceSheet(addServiceController);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomPrimaryButton2(
                  buttonText: "Sell Repost",
                  fontSize: sp(11),
                  buttonHeight: 40,
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    showAddRepostSheet(addServiceController);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomPrimaryButton2(
                  buttonText: "Sell Services",
                  fontSize: sp(11),
                  buttonHeight: 40,
                  onTap: () {
                    final addServiceController = Get.put(
                      AddServiceController(),
                    );
                    addServiceController.clearForm();
                    addServiceController.selectedServiceType.value = 'SERVICE';
                    addServiceController.isSocialService.value = false;
                    showAddServiceSheet(addServiceController);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Stats row with icons
          Row(
            children: [
              Expanded(
                child: StatCard(icon: Icons.shopping_bag_outlined, value: '${user.totaldeals}', label: 'Total Deals'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: StatCard(icon: Icons.attach_money_rounded, value: '\$${user.earnings.toStringAsFixed(2)}', label: 'Earnings'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: StatCard(icon: Icons.star_border_rounded, value: user.rating.toStringAsFixed(1), label: 'Rating'),
              ),
            ],
          ),
        ],
      );
    });
  }
}
