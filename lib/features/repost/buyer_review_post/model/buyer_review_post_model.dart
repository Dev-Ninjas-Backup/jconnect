import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';

class BuyerReviewPostModel {
  final String id;
  final String proofImageUrl;
  final String sellerName;
  final DateTime submittedAt;
  final double amount;
  final RepostStatusItem originalItem;

  final String? proofNote;

  const BuyerReviewPostModel({
    required this.id,
    required this.proofImageUrl,
    required this.sellerName,
    required this.submittedAt,
    required this.amount,
    required this.originalItem,
    this.proofNote,
  });
}
