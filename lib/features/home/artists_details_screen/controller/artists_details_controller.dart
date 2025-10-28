import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/home/artists_details_screen/model/review_rating_model.dart';
import 'package:jconnect/features/home/artists_details_screen/model/social_post_model.dart';

class ArtistsDetailsController extends GetxController {
  final RxList<SocialPostModel> socialPostListItem = <SocialPostModel>[].obs;
  final RxList<ReviewRatingModel> reviewAndRatingListItem = <ReviewRatingModel>[].obs;
  @override
  void onInit() {
    socialPostItems();
    reviewAndRatingItem();

    super.onInit();
  }

  //social post like insta-facebook-youTube-tiktok
  void socialPostItems() {
    socialPostListItem.addAll([
      SocialPostModel(
        iconUrl: Iconpath.instagram,
        title: "Instagram",
        subTitle: "Best for visual posts, reels, and stories",
        rate: 50,
      ),

      SocialPostModel(
        iconUrl: Iconpath.facebook,
        title: "Facebook",
        subTitle: "Great for event promotions and targeted reach",
        rate: 30,
      ),

      SocialPostModel(
        iconUrl: Iconpath.youtube,
        title: "YouTube",
        subTitle: "Best for long-form content, reviews",
        rate: 40,
      ),

      SocialPostModel(
        iconUrl: Iconpath.tiktok,
        title: "TikTok",
        subTitle: "Perfect for short, viral content with high engagement",
        rate: 45,
      ),
    ]);
  }

  //review and rating
  void reviewAndRatingItem() {
    reviewAndRatingListItem.addAll([
      ReviewRatingModel(
        imageUrl: Imagepath.profileImage,
        title: "@SonicMuse",
        subTitle:
            "Got valuable response that helped me launch my track in a big release!",
        rating: 9.5,
      ),

      ReviewRatingModel(
        imageUrl: Imagepath.profileImage,
        title: "@SonicMuse",
        subTitle:
            "Got valuable response that helped me launch my track in a big release!",
        rating: 9.5,
      ),

      ReviewRatingModel(
        imageUrl: Imagepath.profileImage,
        title: "@SonicMuse",
        subTitle:
            "Got valuable response that helped me launch my track in a big release!",
        rating: 9.5,
      ),
    ]);
  }
}
