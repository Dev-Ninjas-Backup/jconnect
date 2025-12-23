import 'package:get/get.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_timeline_step.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    final dynamic arguments = Get.arguments;

    dynamic incoming;
    Map<String, dynamic>? rawJson;

    if (arguments is Map<String, dynamic>) {
      if (arguments['raw'] is Map<String, dynamic>) {
        rawJson = arguments['raw'];
      }
      incoming ??= arguments['order'];
    } else {
      incoming = arguments;
    }

    // 1 Prefer raw API JSON (contains real timeline)
    if (rawJson != null) {
      try {
        order.value = OrderDetailsModel.fromJson(rawJson);
        return;
      } catch (_) {}
    }

    // 2️Already parsed
    if (incoming is OrderDetailsModel) {
      order.value = incoming;
      return;
    }

    // 3️Coming from OrderModel → build + generate timeline
    if (incoming is OrderModel) {
      final price = incoming.price;

      // Extract possible timestamps from the raw JSON when OrderModel lacks them
      final String? createdAtFromRaw = incoming.raw != null
          ? ((incoming.raw!['createdAt'] ?? incoming.raw!['created_at'])
                ?.toString())
          : null;
      final String? deliveryDateFromRaw = incoming.raw != null
          ? ((incoming.raw!['deliveryDate'] ?? incoming.raw!['delivery_date'])
                ?.toString())
          : null;
      final String? updatedAtFromRaw = incoming.raw != null
          ? ((incoming.raw!['updatedAt'] ?? incoming.raw!['updated_at'])
                ?.toString())
          : null;

      order.value = OrderDetailsModel(
        id: incoming.orderId, // internal DB id
        orderCode: incoming.orderCode, // user-facing code
        platform: incoming.platform,
        serviceTitle: incoming.title,
        subServiceTitle: incoming.description ?? '',
        sellerName: incoming.sellerName,
        sellerEmail: incoming.sellerEmail,
        rating: 0.0,
        status: incoming.status,
        orderCreated: createdAtFromRaw ?? '',
        deliveryDate: deliveryDateFromRaw ?? '',
        servicePrice: price,
        platformFee: price,
        // OrderModel does not always include a platformRate; use empty string fallback
        platformRate: '',
        timeline: _generateTimeline(
          status: incoming.status,
          createdAt: createdAtFromRaw,
          deliveryDate: deliveryDateFromRaw,
          updatedAt: updatedAtFromRaw,
        ),
      );
      return;
    }

    // 4️ Fallback raw map
    if (incoming is Map<String, dynamic>) {
      try {
        order.value = OrderDetailsModel.fromJson(incoming);
      } catch (_) {}
    }
  }

  // Generates timeline when API doesn’t provide one
  List<OrderTimelineStep> _generateTimeline({
    required String status,
    String? createdAt,
    String? deliveryDate,
    String? updatedAt,
  }) {
    final steps = [
      'Order has been placed',
      'Waiting for Reviewer',
      'Waiting for proof',
      'Completed',
    ];

    int completedIndex = -1;
    switch (status.toUpperCase()) {
      case 'PENDING':
        completedIndex = -1; // none completed
        break;
      case 'ACTIVE':
        completedIndex = 0;
        break;
      case 'PAYMENTCONFIRM':
      case 'PAYMENT_CONFIRM':
        completedIndex = 1;
        break;
      case 'COMPLETE':
      case 'COMPLETED':
        completedIndex = 3;
        break;
    }

    // Determine first step date according to status
    final updated = updatedAt ?? '';

    final firstStepDate = status.toUpperCase() == 'PENDING'
        ? ''
        : (status.toUpperCase() == 'ACTIVE'
              ? (updated.isNotEmpty ? updated : '')
              : (createdAt ?? ''));

    return List.generate(steps.length, (i) {
      return OrderTimelineStep(
        title: steps[i],
        dateTime: i == 0
            ? firstStepDate
            : i == 3
            ? (deliveryDate ?? '')
            : '',
        isCompleted: i <= completedIndex,
      );
    });
  }
}
