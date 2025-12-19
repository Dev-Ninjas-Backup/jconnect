import 'package:get/get.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    final dynamic arguments = Get.arguments;

    // Handle multiple shapes that might be passed:
    // - Map with key 'order' containing OrderDetailsModel, OrderModel or raw JSON map
    // - An OrderModel directly
    // - An OrderDetailsModel directly

    dynamic incoming;
    Map<String, dynamic>? rawJson;
    if (arguments is Map<String, dynamic>) {
      if (arguments.containsKey('raw') &&
          arguments['raw'] is Map<String, dynamic>) {
        rawJson = arguments['raw'] as Map<String, dynamic>;
      }
      if (arguments.containsKey('order')) incoming = arguments['order'];
    } else if (arguments != null) {
      incoming = arguments;
    }

    // If raw JSON is available prefer building from it (it contains richer data)
    if (rawJson != null) {
      try {
        order.value = OrderDetailsModel.fromJson(rawJson);
      } catch (_) {
        // fallback to other incoming shapes below
      }
      if (order.value != null) return;
    }

    if (incoming == null) return;

    if (incoming is OrderDetailsModel) {
      order.value = incoming;
      return;
    }

    if (incoming is OrderModel) {
      // Map OrderModel to OrderDetailsModel with sensible defaults
      final mapped = OrderDetailsModel(
        id: incoming.orderId ?? '',
        platform: incoming.platform,
        serviceTitle: incoming.title,
        subServiceTitle: incoming.description ?? '',
        reviewerName: incoming.sellerName,
        reviewerHandle: incoming.sellerEmail,
        reviewerImage: incoming.icon,
        rating: 0.0,
        status: incoming.status,
        orderCreated: '',
        deliveryDate: '',
        servicePrice: incoming.price,
        platformFee: (incoming.price * 0.10),
        timeline: [],
      );
      order.value = mapped;
      return;
    }

    if (incoming is Map<String, dynamic>) {
      // Try to build from raw JSON
      try {
        order.value = OrderDetailsModel.fromJson(incoming);
      } catch (_) {
        // If parsing fails, leave order null
      }
      return;
    }
  }
}
