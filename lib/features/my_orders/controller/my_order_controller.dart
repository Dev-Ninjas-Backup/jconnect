import 'package:get/get.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class MyOrdersController extends GetxController {
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxString selectedTab = 'All Orders'.obs;
  RxString selectedOrderType = 'All Orders'.obs;

  List<OrderModel> get filteredOrders {
    var filtered = orders;

    if (selectedOrderType.value != 'All Orders') {
      filtered = filtered
          .where((o) => o.type == selectedOrderType.value)
          .toList()
          .obs;
    }

    if (selectedTab.value != 'All Orders') {
      filtered = filtered
          .where((o) => o.status == selectedTab.value)
          .toList()
          .obs;
    }

    return filtered;
  }

  void loadOrders() {
    orders.assignAll([
      OrderModel(
        platform: 'Instagram',
        title: 'Track Review by DJ Nova',
        status: 'Pending Confirmation',
        price: 50,
        icon: 'assets/icons/instagram.png',
        type: 'Received',
      ),
      OrderModel(
        platform: 'Tiktok',
        title: 'Shoutout on a Story',
        status: 'Active',
        price: 50,
        icon: 'assets/icons/tiktok.png',
        type: 'Given',
      ),
      OrderModel(
        platform: 'Youtube',
        title: 'Shoutout on a Video',
        status: 'Completed',
        price: 50,
        icon: 'assets/icons/youtube.png',
        type: 'Received',
      ),
    ]);
  }

  void clearOrders() => orders.clear();

  void deleteOrder(OrderModel order) {
    orders.remove(order);
  }
}
