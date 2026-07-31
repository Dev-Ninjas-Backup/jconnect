import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/widgets/order_card_wrapper.dart';
import 'package:jconnect/features/my_orders/widgets/order_empty_state.dart';
import 'package:jconnect/features/my_orders/widgets/order_section_header.dart';
import 'package:jconnect/features/my_orders/widgets/order_tab_bar.dart';
import 'package:jconnect/features/repost/repost_status/screen/repost_status.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyOrdersController());

    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadOrders();
    });

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "ORDERS",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
              SizedBox(height: 20),
              
              _MainTabToggle(controller: controller),
              
              SizedBox(height: 20),
              
              Expanded(
                child: Obx(() {
                  if (controller.selectedMainTab.value == OrderMainTab.serviceAndSocialPost) {
                    return _ServiceAndSocialPostView(controller: controller);
                  } else {
                    return const RepostStatusContent();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainTabToggle extends StatelessWidget {
  final MyOrdersController controller;
  const _MainTabToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isService = controller.selectedMainTab.value == OrderMainTab.serviceAndSocialPost;
      
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedMainTab.value = OrderMainTab.serviceAndSocialPost,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isService
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF60000F),
                              Color(0xFFBB0224),
                              Color(0xFF60000F),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Service&SocialPost',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isService ? FontWeight.w600 : FontWeight.w400,
                      color: isService ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedMainTab.value = OrderMainTab.repostService,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: !isService
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF60000F),
                              Color(0xFFBB0224),
                              Color(0xFF60000F),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Repost Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: !isService ? FontWeight.w600 : FontWeight.w400,
                      color: !isService ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ServiceAndSocialPostView extends StatelessWidget {
  final MyOrdersController controller;
  const _ServiceAndSocialPostView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderTabBar(controller: controller),
        SizedBox(height: 20),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.redColor,
                  ),
                ),
              );
            }

            final list = controller.filteredOrders;
            final receivedOrders = list.where((o) => o.type == 'Received').toList();
            final purchasedOrders = list.where((o) => o.type != 'Received').toList();

            return RefreshIndicator(
              color: AppColors.redColor,
              onRefresh: () => controller.loadOrders(),
              child: list.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.5,
                          child: const OrderEmptyState(),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (receivedOrders.isNotEmpty) ...[
                          OrderSectionHeader.received(),
                          SizedBox(height: 4.h),
                          ...receivedOrders.map(
                            (order) => OrderCardWrapper(order: order),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        if (purchasedOrders.isNotEmpty) ...[
                          OrderSectionHeader.purchased(),
                          SizedBox(height: 4.h),
                          ...purchasedOrders.map(
                            (order) => OrderCardWrapper(order: order),
                          ),
                        ],
                      ],
                    ),
            );
          }),
        ),
      ],
    );
  }
}
