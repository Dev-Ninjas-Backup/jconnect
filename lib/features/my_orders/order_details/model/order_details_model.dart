import 'package:get/get.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_timeline_step.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';

class OrderDetailsModel {
  final String id; // database ID
  final String orderCode; // display to user
  final String platform;
  final String serviceTitle;
  final String subServiceTitle;
  final String sellerName;
  final String sellerEmail;
  final String sellerId;
  final double rating;
  final String status;
  final String orderCreated;
  final String deliveryDate;
  final double servicePrice;
  final String platformRate;
  final double platformFee;
  final String buyerId;
  final List<OrderTimelineStep> timeline;

  OrderDetailsModel({
    required this.id,
    required this.orderCode,
    required this.platform,
    required this.serviceTitle,
    required this.subServiceTitle,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerId,
    required this.rating,
    required this.status,
    required this.orderCreated,
    required this.deliveryDate,
    required this.servicePrice,
    required this.platformRate,
    required this.platformFee,
    required this.buyerId,
    required this.timeline,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        final parts = k.split('.');
        dynamic cursor = json;
        bool found = true;
        for (final p in parts) {
          if (cursor is Map && cursor.containsKey(p)) {
            cursor = cursor[p];
          } else {
            found = false;
            break;
          }
        }
        if (found && cursor != null) return cursor.toString();
      }
      return fallback;
    }

    double pickDouble(List<String> keys, [double fallback = 0.0]) {
      for (final k in keys) {
        final parts = k.split('.');
        dynamic cursor = json;
        bool found = true;
        for (final p in parts) {
          if (cursor is Map && cursor.containsKey(p)) {
            cursor = cursor[p];
          } else {
            found = false;
            break;
          }
        }
        if (found && cursor != null) {
          try {
            if (cursor is num) return cursor.toDouble();
            return double.parse(cursor.toString());
          } catch (_) {}
        }
      }
      return fallback;
    }

    final servicePrice = pickDouble(['amount', 'price'], 0.0);
    // Provide explicit fallback to avoid returning null at runtime
    final platformFee = pickDouble(['platformFee'], 0.0);

    // Get seller info from API, fallback to logged-in user if empty
    String sellerName = pickString(['seller.full_name'], '');
    String sellerEmail = pickString(['seller.email'], '');
    String sellerId = pickString(['sellerId'], '');

    // If seller info is empty, try to get logged-in user's info
    if (sellerName.isEmpty || sellerEmail.isEmpty) {
      try {
        final profileController = Get.find<ProfileController>();
        if (sellerName.isEmpty) {
          sellerName = profileController.user.value.name;
        }
        if (sellerEmail.isEmpty) {
          sellerEmail = profileController.user.value.email ?? '';
        }
      } catch (_) {
        // ProfileController not available, keep empty strings
      }
    }

    final result = OrderDetailsModel(
      id: pickString(['id']),
      orderCode: pickString(['orderCode']),
      platform: pickString(['platform', 'service.serviceType']),
      serviceTitle: pickString(['service.serviceName', 'title']),
      subServiceTitle: pickString(['service.description']),
      sellerName: sellerName,
      sellerEmail: sellerEmail,
      sellerId: sellerId,
      rating: pickDouble(['rating', 'review.rating'], 0.0),
      status: pickString(['status'], ''),
      orderCreated: pickString(['createdAt'], ''),
      deliveryDate: pickString(['deliveryDate'], ''),
      servicePrice: servicePrice,
      platformRate: pickString(['platformRate'], ''),
      platformFee: platformFee,
      buyerId: pickString(['buyerId', 'buyer_id'], ''),
      timeline: (() {
        final parsed = (json['timeline'] as List<dynamic>?)
            ?.map(
              (item) =>
                  OrderTimelineStep.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        if (parsed != null && parsed.isNotEmpty) return parsed;

        // If API didn't provide a timeline, generate a reasonable default
        final statusStr = pickString(['status'], '').toUpperCase();
        final created = pickString([
          'createdAt',
          'created_at',
          'orderCreated',
          'order_created',
        ], '');
        final delivery = pickString(['deliveryDate', 'delivery_date'], '');

        final steps = [
          'Order has been placed',
          'Waiting to be Reviewed',
          'Waiting for proof',
          'Completed',
        ];

        int completedIndex = -1;
        switch (statusStr) {
          case 'PENDING':
            completedIndex = -1; // none completed for PENDING
            break;
          case 'ACTIVE':
          case 'IN_PROGRESS':
            completedIndex =
                0; // first step completed when ACTIVE or IN_PROGRESS
            break;
          case 'PROOF_SUBMITTED':
            completedIndex = 2; // waiting for reviewer & proof completed
            break;
          case 'RELEASED':
          case 'COMPLETE':
          case 'COMPLETED':
            completedIndex = 3; // all steps completed
            break;
          case 'PAYMENTCONFIRM':
          case 'PAYMENT_CONFIRM':
            completedIndex = 1;
            break;
        }

        final updated = pickString(['updatedAt'], '');
        String firstStepDate;
        if (statusStr == 'PENDING') {
          // For PENDING do not show any timestamp for the first step
          firstStepDate = '';
        } else if (statusStr == 'ACTIVE' ||
            statusStr == 'IN_PROGRESS' ||
            statusStr == 'PROOF_SUBMITTED' ||
            statusStr == 'RELEASED') {
          // For ACTIVE, IN_PROGRESS, PROOF_SUBMITTED, or RELEASED show updatedAt (if present)
          firstStepDate = updated.isNotEmpty ? updated : '';
        } else {
          // For other statuses fall back to created timestamp
          firstStepDate = created;
        }

        return List.generate(steps.length, (i) {
          // Provide timestamps for intermediate steps when PROOF_SUBMITTED or RELEASED
          String dt = '';
          if (i == 0) dt = firstStepDate;
          if ((i == 1 || i == 2) &&
              (statusStr == 'PROOF_SUBMITTED' || statusStr == 'RELEASED')) {
            dt = updated.isNotEmpty ? updated : '';
          }
          if (i == 3) {
            dt = (statusStr == 'RELEASED' && updated.isNotEmpty)
                ? updated
                : delivery;
          }

          return OrderTimelineStep(
            title: steps[i],
            dateTime: dt,
            isCompleted: i <= completedIndex,
          );
        });
      })(),
    );

    return result;
  }
}
