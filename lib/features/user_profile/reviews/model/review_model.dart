import 'package:jconnect/core/common/constants/imagepath.dart';

class ReviewModel {
  final String reviewerId;
  final String username;
  final double rating;
  final String description;
  final String avatarUrl;

  ReviewModel({
    required this.reviewerId,
    required this.username,
    required this.rating,
    required this.description,
    required this.avatarUrl,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewerId: json['reviewerId'],
      username: json['reviewer']?['full_name'] ?? 'Unknown',
      rating: (json['rating'] as num).toDouble(),
      description: json['reviewText'] ?? '',
      avatarUrl: Imagepath.profileImage, // placeholder, updated later
    );
  }

  ReviewModel copyWith({String? avatarUrl}) {
    return ReviewModel(
      reviewerId: reviewerId,
      username: username,
      rating: rating,
      description: description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
