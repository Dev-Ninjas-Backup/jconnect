import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'order_card_wrapper.dart';
import 'order_section_header.dart';

class OrdersList extends StatelessWidget {
  final MyOrdersController controller = Get.put(MyOrdersController());

  OrdersList({super.key}) {
    controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // List of orders
        Expanded(
          child: Obx(() {
            final orders = controller.filteredOrders;
            if (orders.isEmpty) return const Center(child: Text('No orders found'));

            final receivedOrders = orders.where((o) => o.type == 'Received').toList();
            final purchasedOrders = orders.where((o) => o.type != 'Received').toList();

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (receivedOrders.isNotEmpty) ...[
                  OrderSectionHeader.received(),
                  SizedBox(height: 4.h),
                  ...receivedOrders.map(
                    (order) => OrderCardWrapper(order: order, controller: controller),
                  ),
                  SizedBox(height: 8.h),
                ],
                if (purchasedOrders.isNotEmpty) ...[
                  OrderSectionHeader.purchased(),
                  SizedBox(height: 4.h),
                  ...purchasedOrders.map(
                    (order) => OrderCardWrapper(order: order, controller: controller),
                  ),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }
}

