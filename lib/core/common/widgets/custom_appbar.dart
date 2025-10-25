import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailingIcon;

  const CustomAppBar({super.key, required this.title, this.trailingIcon});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        title,
        style: getTextStyle(
          fontsize: 16,
          fontweight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
      ),
      actions: trailingIcon != null ? [trailingIcon!] : null,
      centerTitle: true,
      backgroundColor: AppColors.backGroundColor,
      elevation: 0,
    );
  }
}
