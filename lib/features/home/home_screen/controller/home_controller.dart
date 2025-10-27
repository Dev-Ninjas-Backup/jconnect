import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/home/home_screen/model/artists_you_know_model.dart';
import 'package:jconnect/features/home/home_screen/model/feature_artists_model.dart';
import 'package:jconnect/features/home/home_screen/model/start_deal_model.dart';
import 'package:jconnect/features/home/home_screen/model/suggested_for_you_model.dart';

class HomeController extends GetxController {
  final RxList<StartDealModel> startDealList = <StartDealModel>[].obs;
  final artistsList = <ArtistsYouKnowModel>[].obs;
  final featureArtistsList = <FeatureArtistsModel>[].obs;
  final suggestedForYouList = <SuggestedForYouModel>[].obs;
  @override
  void onInit() {
    //start deal list
    startDealListItem();
    // artists list
    artistsListItem();
    //feature artists list
    featureArtistsListItem();
    //suggested for you
    suggestedForYouListItem();

    super.onInit();
  }

  void startDealListItem() {
    startDealList.addAll([
      StartDealModel(
        title: "🔥 Weekend Deal – 10% Off on All Deals!",
        subTitle:
            "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
        ontap: () {},
      ),
      StartDealModel(
        title: "🔥 Weekend Deal – 10% Off on All Deals!",
        subTitle:
            "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
        ontap: () {},
      ),
      StartDealModel(
        title: "🔥 Weekend Deal – 10% Off on All Deals!",
        subTitle:
            "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
        ontap: () {},
      ),
    ]);
  }

  void artistsListItem() {
    artistsList.addAll([
      ArtistsYouKnowModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
      ArtistsYouKnowModel(
        imageUrl: Imagepath.profileImage,
        name: "LUNA VYX",
        ammount: 85,
        heading: "Influencer, Promoter",
        services:
            "Promote your music to Kira’s active followers. Includes personalized caption and tag.",
        rating: 5,
        reviews: 80,
      ),
      ArtistsYouKnowModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
    ]);
  }

  void featureArtistsListItem() {
    featureArtistsList.addAll([
      FeatureArtistsModel(
        imageUrl: Imagepath.profileImage,
        name: "DJ Kinseki",
        ammount: 95,
        heading: "Music Reviewer • Club DJ • Producer",
        services:
            "Offers reviews of music. Performs as a DJ in clubs or venues.Creates and produces music tracks.",
        rating: 4.9,
        reviews: 50,
      ),
      FeatureArtistsModel(
        imageUrl: Imagepath.profileImage,
        name: "Lyrik Blaze",
        ammount: 100,
        heading: "Artist • Music Reviewer • Rapper",
        services:
            "Performs rap or hip-hop music. Offers reviews of music. Performs as a general music artist.",
        rating: 3.5,
        reviews: 80,
      ),
      FeatureArtistsModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
    ]);
  }

  void suggestedForYouListItem() {
    suggestedForYouList.addAll([
      SuggestedForYouModel(
        imageUrl: Imagepath.profileImage,
        name: "DJ Kinseki",
        ammount: 95,
        heading: "Music Reviewer • Club DJ • Producer",
        services:
            "Offers reviews of music. Performs as a DJ in clubs or venues.Creates and produces music tracks.",
        rating: 4.9,
        reviews: 50,
      ),
      SuggestedForYouModel(
        imageUrl: Imagepath.profileImage,
        name: "Lyrik Blaze",
        ammount: 100,
        heading: "Artist • Music Reviewer • Rapper",
        services:
            "Performs rap or hip-hop music. Offers reviews of music. Performs as a general music artist.",
        rating: 3.5,
        reviews: 80,
      ),
      SuggestedForYouModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
    ]);
  }
}
