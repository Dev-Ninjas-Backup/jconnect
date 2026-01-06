import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';
import 'package:jconnect/features/my_orders/widgets/order_card.dart';
import 'package:jconnect/routes/approute.dart';

class OrderCardWrapper extends StatelessWidget {
  final OrderModel order;
  final MyOrdersController controller = Get.find();

  OrderCardWrapper({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(order.hashCode),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        controller.deleteOrder(order);
        // EasyLoading.showToast(
        //   'Order "${order.title}" deleted',
        //   toastPosition: EasyLoadingToastPosition.bottom,
        //   duration: Duration(seconds: 2),
        // );
      },
      background: Container(
        color: AppColors.redColor,
        child: const SizedBox.expand(
          child: Icon(Icons.delete, color: Colors.white, size: 32),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Get.toNamed(
          AppRoute.orderDetails,
          // pass both the lightweight OrderModel and the raw JSON (if available)
          arguments: {'order': order, 'raw': order.raw},
        ),
        child: OrderCard(order: order),
      ),
    );
  }
}
