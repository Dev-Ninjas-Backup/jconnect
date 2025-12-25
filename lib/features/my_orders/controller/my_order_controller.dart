// ignore_for_file: avoid_print

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
      case 'My orders':
        return 'PENDING';
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

      final prefsHelper = Get.find<SharedPreferencesHelperController>();
      final token = await prefsHelper.getAccessToken();

      print('🔥 [MY ORDERS] Retrieved token: ${token?.substring(0, 20)}...');

      if (token == null || token.isEmpty) {
        print('❌ [MY ORDERS] No token found - redirecting to login');
        Get.offAllNamed('/login');
        return;
      }

      // Ensure Bearer prefix is included
      String authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

      print(
        '🔥 [MY ORDERS] Making API call to: ${Endpoint.baseUrl}/orders/my_service_orders',
      );
      print('🔥 [MY ORDERS] Auth header: ${authHeader.substring(0, 20)}...');

      // Use the new endpoint for my service orders
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/orders/my_service_orders'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      print('🔥 [MY ORDERS] API Response status: ${response.statusCode}');
      print('🔥 [MY ORDERS] API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        print('🔥 [MY ORDERS] Fetched ${data.length} orders');
        final List<OrderModel> fetchedOrders = data
            .map((json) => OrderModel.fromJson(json))
            .toList();
        orders.assignAll(fetchedOrders);
        print('✅ [MY ORDERS] Orders loaded successfully');
      } else if (response.statusCode == 401) {
        print('❌ [MY ORDERS] Unauthorized - redirecting to login');
        // Clear stored token since it's invalid
        await prefsHelper.clearAllData();
        Get.offAllNamed('/login');
      } else {
        print('❌ [MY ORDERS] Failed to load orders: ${response.statusCode}');
        print('❌ [MY ORDERS] Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ [MY ORDERS] Error loading orders: $e');
      print('❌ [MY ORDERS] Stack trace: $stackTrace');
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
      final prefsHelper = Get.find<SharedPreferencesHelperController>();
      final token = await prefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ [DELETE ORDER] No token available');
        return;
      }

      String authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

      final response = await http.delete(
        Uri.parse('${Endpoint.orders}/${order.orderId}'), // DATABASE ID
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ [DELETE ORDER] Order deleted successfully');
      } else {
        print(
          '❌ [DELETE ORDER] Failed to delete order: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [DELETE ORDER] Error: $e');
    }
  }
}
