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
  final String sellerUsername;
  final String sellerimageUrl;
  final String sellerId;
  final String buyerName;
  final String buyerEmail;
  final String buyerUsername;
  final String buyerImageUrl;
  final double rating;
  final String status;
  final String orderCreated;
  final String deliveryDate;
  final String cancelledAt;
  final double servicePrice;
  final String platformRate;
  final double platformFee;
  final String buyerId;
  final List<OrderTimelineStep> timeline;
  final List<String> proofUrl;
  final bool isCancalProofSubmitted;
  final String captionOrInstructions;
  final String specialNotes;
  final String promotionDate;
  final List<String> files;

  OrderDetailsModel({
    required this.id,
    required this.orderCode,
    required this.platform,
    required this.serviceTitle,
    required this.subServiceTitle,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerUsername,
    required this.sellerimageUrl,
    required this.sellerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerUsername,
    required this.buyerImageUrl,
    required this.rating,
    required this.status,
    required this.orderCreated,
    required this.deliveryDate,
    this.cancelledAt = '',
    required this.servicePrice,
    required this.platformRate,
    required this.platformFee,
    required this.buyerId,
    required this.timeline,
    required this.proofUrl,
    this.isCancalProofSubmitted = false,
    this.captionOrInstructions = '',
    this.specialNotes = '',
    this.promotionDate = '',
    this.files = const [],
  });

  OrderDetailsModel copyWith({
    String? id,
    String? orderCode,
    String? platform,
    String? serviceTitle,
    String? subServiceTitle,
    String? sellerName,
    String? sellerEmail,
    String? sellerUsername,
    String? sellerimageUrl,
    String? sellerId,
    String? buyerName,
    String? buyerEmail,
    String? buyerUsername,
    String? buyerImageUrl,
    double? rating,
    String? status,
    String? orderCreated,
    String? deliveryDate,
    String? cancelledAt,
    double? servicePrice,
    String? platformRate,
    double? platformFee,
    String? buyerId,
    List<OrderTimelineStep>? timeline,
    List<String>? proofUrl,
    bool? isCancalProofSubmitted,
    String? captionOrInstructions,
    String? specialNotes,
    String? promotionDate,
    List<String>? files,
  }) {
    return OrderDetailsModel(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      platform: platform ?? this.platform,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      subServiceTitle: subServiceTitle ?? this.subServiceTitle,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerimageUrl: sellerimageUrl ?? this.sellerimageUrl,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyerUsername: buyerUsername ?? this.buyerUsername,
      buyerImageUrl: buyerImageUrl ?? this.buyerImageUrl,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      orderCreated: orderCreated ?? this.orderCreated,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      servicePrice: servicePrice ?? this.servicePrice,
      platformRate: platformRate ?? this.platformRate,
      platformFee: platformFee ?? this.platformFee,
      buyerId: buyerId ?? this.buyerId,
      timeline: timeline ?? this.timeline,
      proofUrl: proofUrl ?? this.proofUrl,
      isCancalProofSubmitted: isCancalProofSubmitted ?? this.isCancalProofSubmitted,
      captionOrInstructions: captionOrInstructions ?? this.captionOrInstructions,
      specialNotes: specialNotes ?? this.specialNotes,
      promotionDate: promotionDate ?? this.promotionDate,
      files: files ?? this.files,
    );
  }

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
    final platformFee = pickDouble(['platformFee'], 0.0);
    String sellerName = pickString(['seller.full_name'], '');
    String sellerUsername = pickString(['seller.username'], '');
    String sellerImage = pickString(['seller.profilePhoto'], '');
    String sellerEmail = pickString(['seller.email'], '');
    String sellerId = pickString(['sellerId'], '');

    // Extract buyer info
    String buyerName = pickString(['buyer.full_name'], '');
    String buyerUsername = pickString(['buyer.username'], '');
    String buyerImage = pickString(['buyer.profilePhoto'], '');
    String buyerEmail = pickString(['buyer.email'], '');

    if (sellerName.isEmpty || sellerEmail.isEmpty) {
      try {
        final profileController = Get.find<ProfileController>();
        if (sellerName.isEmpty) {
          sellerName = profileController.user.value.name;
        }
        if (sellerUsername.isEmpty) {
          sellerUsername = profileController.user.value.username;
        }
        if (sellerImage.isEmpty) {
          try {
            final profileController = Get.find<ProfileController>();
            sellerImage = profileController.user.value.imageUrl;
          } catch (_) {}
        }
        if (sellerEmail.isEmpty) {
          sellerEmail = profileController.user.value.email ?? '';
        }
      } catch (_) {}
    }

    List<String> proofUrlList = [];
    if (json['proofUrl'] != null) {
      if (json['proofUrl'] is List) {
        proofUrlList = (json['proofUrl'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (json['proofUrl'] is String) {
        proofUrlList = [json['proofUrl'].toString()];
      }
    }

    bool isCancalProofSubmitted = false;
    if (json['isCancalProofSubmitted'] != null) {
      isCancalProofSubmitted =
          json['isCancalProofSubmitted'] == true ||
          json['isCancalProofSubmitted'] == 1 ||
          json['isCancalProofSubmitted'] == '1' ||
          json['isCancalProofSubmitted'] == 'true';
    }

    List<String> filesList = [];
    if (json['files'] != null) {
      if (json['files'] is List) {
        filesList = (json['files'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (json['files'] is String) {
        filesList = [json['files'].toString()];
      }
    }

    final cancelledAt = pickString(['cancelledAt', 'cancelled_at'], '');

    final result = OrderDetailsModel(
      id: pickString(['id']),
      orderCode: pickString(['orderCode']),
      platform: pickString(['platform', 'service.serviceType']),
      serviceTitle: pickString(['service.serviceName', 'title']),
      subServiceTitle: pickString(['service.description']),
      sellerName: sellerName,
      sellerEmail: sellerEmail,
      sellerUsername: sellerUsername,
      sellerimageUrl: sellerImage,
      sellerId: sellerId,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      buyerUsername: buyerUsername,
      buyerImageUrl: buyerImage,
      rating: pickDouble(['rating', 'review.rating'], 0.0),
      status: pickString(['status'], ''),
      orderCreated: pickString(['createdAt'], ''),
      deliveryDate: pickString(['deliveryDate'], ''),
      cancelledAt: cancelledAt,
      servicePrice: servicePrice,
      platformRate: pickString(['platformFee_percents'], ''),
      platformFee: platformFee,
      buyerId: pickString(['buyerId', 'buyer_id'], ''),
      proofUrl: proofUrlList,
      isCancalProofSubmitted: isCancalProofSubmitted,
      captionOrInstructions: pickString(['captionOrInstructions']),
      specialNotes: pickString(['specialNotes']),
      promotionDate: pickString(['promotionDate']),
      files: filesList,
      timeline: (() {
        final rawTimeline = json['timeline'] as List<dynamic>?;
        final statusStr = pickString(['status'], '').toUpperCase();

        if (rawTimeline != null && rawTimeline.isNotEmpty) {
          final parsed = rawTimeline
              .map((item) => OrderTimelineStep.fromJson(item as Map<String, dynamic>))
              .toList();

          final isCompletedAll = statusStr == 'RELEASED' || statusStr == 'COMPLETE' || statusStr == 'COMPLETED';

          return List.generate(parsed.length, (i) {
            final step = parsed[i];
            bool completed = step.isCompleted || isCompletedAll;
            if (step.dateTime.isNotEmpty) {
              completed = true;
            } else if (i == 0) {
              completed = true;
            }
            return OrderTimelineStep(
              title: step.title,
              dateTime: step.dateTime,
              isCompleted: completed,
              description: step.description,
            );
          });
        }

        // If API didn't provide a timeline, generate timeline steps with timestamps
        final created = pickString([
          'createdAt',
          'created_at',
          'orderCreated',
          'order_created',
        ], '');
        final inProgressAt = pickString(['inProgressAt', 'in_progress_at'], '');
        final proofSubmittedAt = pickString(['proofSubmittedAt', 'proof_submitted_at'], '');
        final resubmitAt = pickString(['resubmitAt', 'resubmit_at'], '');
        final releasedAt = pickString(['releasedAt', 'released_at'], '');
        final cancelledAt = pickString(['cancelledAt', 'cancelled_at'], '');
        final delivery = pickString(['deliveryDate', 'delivery_date'], '');
        final updated = pickString(['updatedAt'], '');
        final resubmitReason = pickString([
          'resubmitReason',
          'rejectReason',
          'reason',
          'description',
        ], '');

        final isResubmitState = statusStr == 'RESUBMIT' || isCancalProofSubmitted;

        final List<OrderTimelineStep> stepsList = [];

        // 1. Order Placed step
        stepsList.add(
          OrderTimelineStep(
            title: 'Order has been placed',
            dateTime: created,
            isCompleted: true,
          ),
        );

        // 2. In Progress / Reviewed step
        final inProgressDate = inProgressAt.isNotEmpty
            ? inProgressAt
            : (statusStr != 'PENDING' ? (updated.isNotEmpty ? updated : created) : '');
        stepsList.add(
          OrderTimelineStep(
            title: 'Waiting to be Reviewed',
            dateTime: inProgressDate,
            isCompleted: statusStr != 'PENDING',
          ),
        );

        // 3. Proof Submitted step
        final proofDate = proofSubmittedAt.isNotEmpty
            ? proofSubmittedAt
            : ((statusStr == 'PROOF_SUBMITTED' || isResubmitState || statusStr == 'RELEASED')
                ? updated
                : '');
        stepsList.add(
          OrderTimelineStep(
            title: 'Waiting for proof',
            dateTime: proofDate,
            isCompleted: statusStr == 'PROOF_SUBMITTED' || statusStr == 'RELEASED',
          ),
        );

        // 4. If RESUBMIT status or proof was rejected, show Resubmit step with description
        if (isResubmitState) {
          final resubmitDate = resubmitAt.isNotEmpty ? resubmitAt : updated;
          stepsList.add(
            OrderTimelineStep(
              title: 'Proof Rejected - Resubmit Required',
              dateTime: resubmitDate,
              isCompleted: true,
              description: resubmitReason.isNotEmpty ? resubmitReason : null,
            ),
          );
        }

        // 5. Completed step
        final completedDate = releasedAt.isNotEmpty
            ? releasedAt
            : (statusStr == 'RELEASED' ? (updated.isNotEmpty ? updated : delivery) : '');
        stepsList.add(
          OrderTimelineStep(
            title: statusStr == 'CANCELLED' ? 'Order Cancelled' : 'Completed',
            dateTime: statusStr == 'CANCELLED'
                ? (cancelledAt.isNotEmpty ? cancelledAt : updated)
                : completedDate,
            isCompleted: statusStr == 'RELEASED' || statusStr == 'COMPLETE' || statusStr == 'COMPLETED' || statusStr == 'CANCELLED',
          ),
        );

        return stepsList;
      })(),
    );

    return result;
  }
}
