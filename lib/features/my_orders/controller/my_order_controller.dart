// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class MyOrdersController extends GetxController {
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxList<OrderModel> paidOrders = <OrderModel>[].obs;
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
      case 'Paid Orders':
        return 'PAID';
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

    // Handle Paid Orders specially - show all paid orders regardless of status
    if (selectedTab.value == 'Paid Orders') {
      return paidOrders.where((order) {
        final typeMatch =
            selectedOrderType.value == 'All Orders' ||
            order.type == selectedOrderType.value;
        return typeMatch;
      }).toList();
    }

    // Combine both service orders and paid orders for other tabs
    List<OrderModel> allOrders = [];
    if (selectedTab.value == 'All Orders') {
      allOrders = [...orders, ...paidOrders];
    } else {
      allOrders = [...orders];
    }

    return allOrders.where((order) {
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

      // Load both service orders and paid orders
      await Future.wait([_loadServiceOrders(), _loadPaidOrders()]);
    } catch (e, stackTrace) {
      print('❌ [MY ORDERS] Error loading orders: $e');
      print('❌ [MY ORDERS] Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadServiceOrders() async {
    try {
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

      // Use the existing endpoint for my service orders
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
        print('🔥 [MY ORDERS] Fetched ${data.length} service orders');
        final List<OrderModel> fetchedOrders = data
            .map((json) => OrderModel.fromJson(json))
            .toList();
        orders.assignAll(fetchedOrders);
        print('✅ [MY ORDERS] Service orders loaded successfully');
      } else if (response.statusCode == 401) {
        print('❌ [MY ORDERS] Unauthorized - redirecting to login');
        // Clear stored token since it's invalid
        await prefsHelper.clearAllData();
        Get.offAllNamed('/login');
      } else {
        print(
          '❌ [MY ORDERS] Failed to load service orders: ${response.statusCode}',
        );
        print('❌ [MY ORDERS] Response: ${response.body}');
      }
    } catch (e) {
      print('❌ [MY ORDERS] Error loading service orders: $e');
    }
  }

  Future<void> _loadPaidOrders() async {
    try {
      final prefsHelper = Get.find<SharedPreferencesHelperController>();
      final token = await prefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ [PAID ORDERS] No token found');
        return;
      }

      // Ensure Bearer prefix is included
      String authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

      print(
        '🔥 [PAID ORDERS] Making API call to: ${Endpoint.baseUrl}/orders/my-orders',
      );

      // Use the new endpoint for paid orders
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/orders/my-orders'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      print('🔥 [PAID ORDERS] API Response status: ${response.statusCode}');
      print('🔥 [PAID ORDERS] API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        print('🔥 [PAID ORDERS] Fetched ${data.length} paid orders');
        final List<OrderModel> fetchedPaidOrders = data
            .map((json) => OrderModel.fromPaidOrderJson(json))
            .toList();
        paidOrders.assignAll(fetchedPaidOrders);
        print('✅ [PAID ORDERS] Paid orders loaded successfully');
      } else {
        print(
          '❌ [PAID ORDERS] Failed to load paid orders: ${response.statusCode}',
        );
        print('❌ [PAID ORDERS] Response: ${response.body}');
      }
    } catch (e) {
      print('❌ [PAID ORDERS] Error loading paid orders: $e');
    }
  }

  void clearOrders() {
    orders.clear();
    paidOrders.clear();
  }

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

  Future<void> updateOrderStatus({
  required String orderId,
  required OrderStatus status,
}) async {
  try {
    final prefsHelper = Get.find<SharedPreferencesHelperController>();
    final token = await prefsHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      print('❌ [ORDER STATUS] No token found');
      return;
    }

    final authHeader =
        token.startsWith('Bearer ') ? token : 'Bearer $token';

    final url =
        '${Endpoint.baseUrl}/orders/$orderId/status?status=${status.name}';

    print('🔥 [ORDER STATUS] PUT → $url');

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      },
    );

    print('🔥 [ORDER STATUS] Status: ${response.statusCode}');
    print('🔥 [ORDER STATUS] Body: ${response.body}');

    if (response.statusCode == 200) {
      // Update locally
      _updateLocalOrderStatus(orderId, status.name);
      print('✅ [ORDER STATUS] Updated successfully');
    } else {
      print(
        '❌ [ORDER STATUS] Failed: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('❌ [ORDER STATUS] Error: $e');
  }
}
void _updateLocalOrderStatus(String orderId, String status) {
  for (final list in [orders, paidOrders]) {
    final index =
        list.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      list[index] = list[index].copyWith(status: status);
    }
  }
}


}

// ignore: constant_identifier_names
enum OrderStatus { CANCELLED, PENDING, IN_PROGRESS, PROOF_SUBMITTED }
