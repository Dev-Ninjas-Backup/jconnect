import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';

class OrderAppbar extends StatelessWidget {
  final String title;
  final String actionIconUrl;
  final VoidCallback? actionOnTap;

  const OrderAppbar({
    super.key,
    required this.title,
    required this.actionIconUrl,
    this.actionOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              color: Colors.white,
              fontsize: 20,
              fontweight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (details) {
            final position = details.globalPosition;
            showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx - 100,
                position.dy + 10,
                position.dx,
                position.dy,
              ),
              color: const Color(0xFF2A2A2D),
              items: [
                PopupMenuItem(
                  value: 'All Orders',
                  child: Text(
                    'All Orders',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                ),
                PopupMenuItem(
                  value: 'Received',
                  child: Text(
                    'Received Orders',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                ),
                PopupMenuItem(
                  value: 'Given',
                  child: Text(
                    'Given Orders',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                ),
              ],
            ).then((value) {
              if (value != null) controller.selectedOrderType.value = value;
            });
          },
          child: Image.asset(actionIconUrl, width: 28.h, height: 28.w),
        ),
      ],
    );
  }
}
