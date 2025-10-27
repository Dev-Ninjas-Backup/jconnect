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
        title: 'Instagram Follower Boost',
        platform: 'Instagram',
        icon: 'assets/icons/instagram.png',
        type: 'Given',
        status: 'Active',
        price: 29,
        description: '1000 organic followers, 3-day delivery.',
      ),
      OrderModel(
        title: 'Facebook Page Likes',
        platform: 'Facebook',
        icon: 'assets/icons/facebook.png',
        type: 'Received',
        status: 'Completed',
        price: 15,
        description: 'Boosted through ad campaign in July.',
      ),
      OrderModel(
        title: 'YouTube Watch Hours',
        platform: 'YouTube',
        icon: 'assets/icons/youtube.png',
        type: 'Given',
        status: 'Pending Confirmation',
        price: 40,
        description: '4000 hours target, pending verification.',
      ),
    ]);
  }

  void clearOrders() => orders.clear();

  void deleteOrder(OrderModel order) {
    orders.remove(order);
  }
}
