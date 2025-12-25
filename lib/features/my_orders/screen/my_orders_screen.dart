import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/constants/order_appbar.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/widgets/order_card_wrapper.dart';
import 'package:jconnect/features/my_orders/widgets/order_empty_state.dart';
import 'package:jconnect/features/my_orders/widgets/order_tab_bar.dart';

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
              OrderAppbar(
                title: 'My Orders',
                actionIconUrl: Iconpath.filterIcon,
              ),
              SizedBox(height: 20),
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

                  if (controller.orders.isEmpty) {
                    return OrderEmptyState();
                  }

                  final list = controller.filteredOrders;
                  if (list.isEmpty) {
                    return OrderEmptyState();
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) =>
                        OrderCardWrapper(order: list[index]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
