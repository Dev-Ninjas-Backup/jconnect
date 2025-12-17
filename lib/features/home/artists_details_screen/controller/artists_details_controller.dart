import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/model/social_post_model.dart';

import '../../home_screen/model/artists_model.dart';
import '../model/service_model.dart';

class ArtistsDetailsController extends GetxController {
  final NetworkClient networkClient;

  ArtistsDetailsController({required this.networkClient});
  final RxList<SocialPostModel> socialPostListItem = <SocialPostModel>[].obs;
  // final RxList<ReviewRatingModel> reviewAndRatingListItem =
  //     <ReviewRatingModel>[].obs;
  var serviceListItem = <ServiceModel1>[].obs;

  var isLoading = false.obs;
  var artistsDetails = Rxn<ArtistsModel>();

  final RxString selectSocialOrService = "social".obs;
  @override
  void onInit() {
    socialPostItems();
    // reviewAndRatingItem();
    serviceItem();

    super.onInit();
  }

  Future<void> fetchArtistById(String id) async {
    try {
      isLoading(true);
      final response = await networkClient.getRequest(
        url: 'https://jconnect-server.saikat.com.bd/users/$id',
      );

      if (response.isSuccess &&
          response.responseData != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        artistsDetails.value = ArtistsModel.fromJson(response.responseData!);
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch artist',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
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

  //service
  void serviceItem() {
    serviceListItem.addAll([
      ServiceModel1(
        title: "Social Shoutout",
        subTitle:
            "Get featured in a story or post from a verified DJ to boost your reach",
        rate: 3.5,
      ),

      ServiceModel1(
        title: "Social Shoutout",
        subTitle:
            "Get featured in a story or post from a verified DJ to boost your reach",
        rate: 3.5,
      ),

      ServiceModel1(
        title: "Social Shoutout",
        subTitle:
            "Get featured in a story or post from a verified DJ to boost your reach",
        rate: 3.5,
      ),

      ServiceModel1(
        title: "Social Shoutout",
        subTitle:
            "Get featured in a story or post from a verified DJ to boost your reach",
        rate: 3.5,
      ),

      ServiceModel1(
        title: "Social Shoutout",
        subTitle:
            "Get featured in a story or post from a verified DJ to boost your reach",
        rate: 3.5,
      ),
    ]);
  }

  //review and rating
  // void reviewAndRatingItem() {
  //   reviewAndRatingListItem.addAll([
  //     ReviewRatingModel(
  //       imageUrl: Imagepath.profileImage,
  //       title: "@SonicMuse",
  //       subTitle:
  //           "Got valuable response that helped me launch my track in a big release!",
  //       rating: 9.5,
  //     ),

  //     ReviewRatingModel(
  //       imageUrl: Imagepath.profileImage,
  //       title: "@SonicMuse",
  //       subTitle:
  //           "Got valuable response that helped me launch my track in a big release!",
  //       rating: 9.5,
  //     ),

  //     ReviewRatingModel(
  //       imageUrl: Imagepath.profileImage,
  //       title: "@SonicMuse",
  //       subTitle:
  //           "Got valuable response that helped me launch my track in a big release!",
  //       rating: 9.5,
  //     ),
  //   ]);
  // }
}
