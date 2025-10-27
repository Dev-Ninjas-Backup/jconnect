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
}
