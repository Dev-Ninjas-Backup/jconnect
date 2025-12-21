// ignore_for_file: curly_braces_in_flow_control_structures

class OrderDetailsModel {
  final String id;
  final String platform;
  final String serviceTitle;
  final String subServiceTitle;
  final String reviewerName;
  final String reviewerHandle;
  final String reviewerImage;
  final double rating;
  final String status;
  final String orderCreated;
  final String deliveryDate;
  final double servicePrice;
  final double platformFee;
  final List<TimelineStep> timeline;

  double get total => servicePrice + platformFee;

  OrderDetailsModel({
    required this.id,
    required this.platform,
    required this.serviceTitle,
    required this.subServiceTitle,
    required this.reviewerName,
    required this.reviewerHandle,
    required this.reviewerImage,
    required this.rating,
    required this.status,
    required this.orderCreated,
    required this.deliveryDate,
    required this.servicePrice,
    required this.platformFee,
    required this.timeline,
  });
  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    // Helper to coalesce multiple possible keys and shapes coming from API
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
          } catch (_) {
            // ignore parse errors
          }
        }
      }
      return fallback;
    }

    final servicePrice = pickDouble(['amount', 'price'], 0.0);
    final platformFee = pickDouble([
      'platformFee',
      'platform_fee',
    ], (servicePrice * 0.10));

    final result = OrderDetailsModel(
      // Prefer orderCode when available (API returns orderCode), fall back to id/_id
      id: pickString(['orderCode']),
      platform: pickString(['platform', 'service.serviceType', 'serviceType']),
      serviceTitle: pickString([
        'serviceTitle',
        'service.serviceName',
        'service.name',
        'title',
      ]),
      subServiceTitle: pickString([
        'subServiceTitle',
        'service.description',
        //'description',
      ]),
      reviewerName: pickString(['seller.full_name'], ''),
      reviewerHandle: pickString(['seller.email'], ''),
      reviewerImage: pickString([
        'reviewerImage',
        'seller.profile_image',
        'seller.image',
        'seller.avatar',
      ], ''),
      rating: pickDouble(['rating', 'review.rating', 'seller.rating'], 0.0),
      status: pickString(['status'], ''),
      orderCreated: pickString(['createdAt'], ''),
      deliveryDate: pickString([
        'deliveryDate',
        'delivery_date',
        'dueDate',
      ], ''),
      servicePrice: servicePrice,
      platformFee: platformFee,
      timeline:
          (json['timeline'] as List<dynamic>?)?.map((item) {
            if (item is Map<String, dynamic>) {
              return TimelineStep.fromJson(item);
            }
            return TimelineStep.fromJson({
              'title': item.toString(),
              'dateTime': '',
              'isCompleted': false,
            });
          }).toList() ??
          [],
    );

    if (result.timeline.isEmpty) {
      // Build default timeline
      final created = result.orderCreated;
      final delivery = result.deliveryDate;
      final proofSubmitted = pickString([
        'proofSubmittedAt',
        'proof_submitted_at',
      ], '');
      // Define ordered steps
      final stepTitles = [
        'Order has been placed',
        'Waiting for Reviewer',
        'Waiting for proof',
        'Completed',
      ];

      int lastCompletedIndex = -1;
      final st = result.status.toUpperCase();
      if (st == 'PENDING')
        lastCompletedIndex = 0;
      else if (st == 'ACTIVE' || st == 'PAYMENTCONFIRM')
        lastCompletedIndex = 1;
      else if (st == 'COMPLETE' || st == 'COMPLETED')
        lastCompletedIndex = 3;
      else if (st == 'CANCELLED' || st == 'CANCEL')
        lastCompletedIndex = -1;

      final generated = <TimelineStep>[];
      for (var i = 0; i < stepTitles.length; i++) {
        final title = stepTitles[i];
        String dateTime = '';
        if (i == 0 && created.isNotEmpty) dateTime = created;
        if (i == 2 && proofSubmitted.isNotEmpty) dateTime = proofSubmitted;
        if (i == 3 && delivery.isNotEmpty) dateTime = delivery;
        generated.add(
          TimelineStep(
            title: title,
            dateTime: dateTime,
            isCompleted: i <= lastCompletedIndex,
          ),
        );
      }

      return OrderDetailsModel(
        id: result.id,
        platform: result.platform,
        serviceTitle: result.serviceTitle,
        subServiceTitle: result.subServiceTitle,
        reviewerName: result.reviewerName,
        reviewerHandle: result.reviewerHandle,
        reviewerImage: result.reviewerImage,
        rating: result.rating,
        status: result.status,
        orderCreated: result.orderCreated,
        deliveryDate: result.deliveryDate,
        servicePrice: result.servicePrice,
        platformFee: result.platformFee,
        timeline: generated,
      );
    }

    return result;
  }
}

class TimelineStep {
  final String title;
  final String dateTime;
  final bool isCompleted;

  TimelineStep({
    required this.title,
    required this.dateTime,
    required this.isCompleted,
  });
  factory TimelineStep.fromJson(Map<String, dynamic> json) {
    return TimelineStep(
      title: json['title'] ?? '',
      dateTime: json['dateTime'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
