import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/user_profile/reviews/model/review_model.dart';

class ReviewController extends GetxController {
  // List of review data
  var reviews = [
    ReviewModel(
      username: '@SonicMuse',
      rating: 4.9,
      description:
          'Got valuable response that helped me launch my track in a big release!',
      avatarUrl: Imagepath.profileImage,
    ),
    ReviewModel(
      username: '@WaveRider',
      rating: 5.0,
      description:
          'Very professional and on-time delivery. Loved the detailed review and insights.',
      avatarUrl: Imagepath.profileImage,
    ),
    ReviewModel(
      username: '@BeatFlare',
      rating: 4.8,
      description:
          'Great experience! Clear communication and honest feedback that truly helped me grow.',
      avatarUrl: Imagepath.profileImage,
    ),
    ReviewModel(
      username: '@BeatFlare',
      rating: 4.8,
      description:
          'Great experience! Clear communication and honest feedback that truly helped me grow.',
      avatarUrl: Imagepath.profileImage,
    ),
    ReviewModel(
      username: '@BeatFlare',
      rating: 4.8,
      description:
          'Great experience! Clear communication and honest feedback that truly helped me grow.',
      avatarUrl: Imagepath.profileImage,
    ),
  ].obs;

  // Add more reviews if needed
  void addReview(ReviewModel review) {
    reviews.add(review);
  }
}
