import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class MyOrdersController extends GetxController {
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxString selectedTab = 'All Orders'.obs;
  RxString selectedOrderType = 'All Orders'.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Map tab label to API status
  String? _mapTabToApiStatus(String tab) {
    switch (tab) {
      case 'Active':
        return 'ACTIVE';
      case 'Pending Confirmation':
        return 'PAYMENTCONFIRM';
      case 'Pending':
        return 'PENDING';
      case 'Completed':
        return 'COMPLETE';
      case 'Cancelled':
        return 'CANCELLED';
      case 'All Orders':
        return null;
      default:
        return null;
    }
  }

  List<OrderModel> get filteredOrders {
    final apiStatus = _mapTabToApiStatus(selectedTab.value);

    return orders.where((order) {
      final statusMatch = apiStatus == null || order.status == apiStatus;
      final typeMatch =
          selectedOrderType.value == 'All Orders' ||
          order.type == selectedOrderType.value;
      return statusMatch && typeMatch;
    }).toList();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;

      final prefsHelper = SharedPreferencesHelperController();
      final token = await prefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse(Endpoint.orders),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final List<OrderModel> fetchedOrders =
            data.map((json) => OrderModel.fromJson(json)).toList();
        orders.assignAll(fetchedOrders);
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearOrders() => orders.clear();

  void deleteOrder(OrderModel order) {
    orders.remove(order);
    _deleteOrderFromServer(order);
  }

  Future<void> _deleteOrderFromServer(OrderModel order) async {
    try {
      final prefsHelper = SharedPreferencesHelperController();
      final token = await prefsHelper.getAccessToken();

      final response = await http.delete(
        Uri.parse('${Endpoint.orders}/${order.orderId}'), // DATABASE ID
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Order deleted successfully');
      } else {
        print('Failed to delete order');
      }
    } catch (e) {
      print('Delete order error: $e');
    }
  }
}
