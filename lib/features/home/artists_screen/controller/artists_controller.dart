import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/home/artists_screen/model/artists_item_model.dart';

class ArtistsController extends GetxController {
  var searchTextController = TextEditingController();
  final RxInt selectArtistsItemIndex = 0.obs;
  final artistsItems = <ArtistsItemModel>[].obs;

  final RxList<String> artistItemTab = [
    'All Artists',
    'Featured Artists',
    'Rising Stars',
    'Top Rated',
    'Most Active',
  ].obs;
  @override
  void onInit() {
    artistsItem();
    super.onInit();
  }

  void artistsItem() {
    artistsItems.addAll([
      ArtistsItemModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
      ArtistsItemModel(
        imageUrl: Imagepath.profileImage,
        name: "LUNA VYX",
        ammount: 85,
        heading: "Influencer, Promoter",
        services:
            "Promote your music to Kira’s active followers. Includes personalized caption and tag.",
        rating: 5,
        reviews: 80,
      ),
      ArtistsItemModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
      ArtistsItemModel(
        imageUrl: Imagepath.profileImage,
        name: "KIRA SOUL",
        ammount: 95,
        heading: "Singer • Influencer • Lyric Reviewer",
        services:
            "Get detailed feedback on your track’s lyrics, melody, and flow perfect for upcoming artists refining their sound.",
        rating: 4,
        reviews: 50,
      ),
      ArtistsItemModel(
        imageUrl: Imagepath.profileImage,
        name: "LUNA VYX",
        ammount: 85,
        heading: "Influencer, Promoter",
        services:
            "Promote your music to Kira’s active followers. Includes personalized caption and tag.",
        rating: 5,
        reviews: 80,
      ),
      ArtistsItemModel(
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
