import 'package:jconnect/features/repost/repost_status/controller/repost_status_controller.dart';

class RepostStatusItem {
  final String id;
  final String platform;
  final String contentUrl;
  final String sellerName;
  final double amount;
  final RepostStatusType status;
  final DateTime createdAt;
  final String timeframe;

  const RepostStatusItem({
    required this.id,
    required this.platform,
    required this.contentUrl,
    required this.sellerName,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.timeframe,
  });
}