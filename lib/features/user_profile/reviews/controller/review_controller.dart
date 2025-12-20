import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/reviews/model/review_model.dart';

class ReviewController extends GetxController {
  var reviews = <ReviewModel>[].obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      isLoading.value = true;

      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ Token not found');
        return;
      }

      final response = await http.get(
        Uri.parse(Endpoint.getReview),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List reviewList = decoded['reviews'] ?? [];
        final tempReviews =
            reviewList.map((e) => ReviewModel.fromJson(e)).toList();

        reviews.assignAll(tempReviews);

        averageRating.value =
            (decoded['averageRating'] as num?)?.toDouble() ?? 0.0;
        totalReviews.value = decoded['totalReviews'] ?? 0;

        print('✅ Reviews Loaded: ${reviews.length}');

        // Fetch reviewer images after reviews loaded
        await fetchReviewerImages(tempReviews);
      } else {
        print('❌ Review API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Review Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch reviewer profile images using reviewerId
  Future<void> fetchReviewerImages(List<ReviewModel> reviewsList) async {
    final prefs = SharedPreferencesHelperController();
    final token = await prefs.getAccessToken();
    if (token == null || token.isEmpty) return;

    final reviewerIds = reviewsList.map((e) => e.reviewerId).toSet().toList();
    final Map<String, String> imageMap = {};

    for (final id in reviewerIds) {
      try {
        final response = await http.get(
          Uri.parse('${Endpoint.baseUrl}/users/$id'),
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final image = decoded['profilePhoto'];
          if (image != null && image.toString().isNotEmpty) {
            imageMap[id] = image;
          }
        }
      } catch (_) {
        // silently ignore individual failures
      }
    }

    // Update reviews with fetched images
    final updatedReviews = reviews.map((review) {
      return review.copyWith(avatarUrl: imageMap[review.reviewerId]);
    }).toList();

    reviews.assignAll(updatedReviews);
  }
}
