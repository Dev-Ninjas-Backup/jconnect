import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'order_card_wrapper.dart';

class OrdersList extends StatelessWidget {
  final MyOrdersController controller = Get.put(MyOrdersController());

  OrdersList({super.key}) {
    controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown for order type filter
        // Obx(
        //   () => DropdownButton<String>(
        //     value: controller.selectedOrderType.value,
        //     items: [
        //       'All Orders',
        //       'Given',
        //       'Received',
        //     ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        //     onChanged: (v) =>
        //         controller.selectedOrderType.value = v ?? 'All Orders',
        //   ),
        // ),
        // Obx(
        //   () => Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children:
        //         ['All Orders', 'Active', 'Pending Confirmation', 'Completed']
        //             .map(
        //               (tab) => GestureDetector(
        //                 onTap: () => controller.selectedTab.value = tab,
        //                 child: Container(
        //                   padding: EdgeInsets.symmetric(
        //                     vertical: 8,
        //                     horizontal: 12,
        //                   ),
        //                   decoration: BoxDecoration(
        //                     color: controller.selectedTab.value == tab
        //                         ? Colors.blue
        //                         : Colors.grey[800],
        //                     borderRadius: BorderRadius.circular(6),
        //                   ),
        //                   child: Text(
        //                     tab,
        //                     style: TextStyle(color: Colors.white),
        //                   ),
        //                 ),
        //               ),
        //             )
        //             .toList(),
        //   ),
        // ),
        // List of orders
        Expanded(
          child: Obx(() {
            final orders = controller.filteredOrders;
            if (orders.isEmpty) return Center(child: Text('No orders found'));
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (_, index) => OrderCardWrapper(order: orders[index]),
            );
          }),
        ),
      ],
    );
  }
}
