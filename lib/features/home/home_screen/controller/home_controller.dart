// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/services/home_service.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/home/home_screen/model/start_deal_model.dart';

import '../model/spotlight_listings_model.dart';

class HomeController extends GetxController {
  final HomeService service = HomeService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) {
          print("unauthorized");
        }
      },
    ),
  );
  SharedPreferencesHelperController sharedPreferencesHelperController = Get.put(
    SharedPreferencesHelperController(),
  );

  final RxList<StartDealModel> startDealList = <StartDealModel>[].obs;
  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;
  final selectedCategoryIndex = 0.obs;

  // Your list of artists
  var recentArtistsList = <ArtistsModel>[].obs;
  final topRatedArtistsList = <ArtistsModel>[].obs;
  final suggestedForYouList = <ArtistsModel>[].obs;
  @override
  void onInit() {
    //start deal list
    startDealListItem();
    // artists list (initial category is SOCIAL_POST corresponding to index 0)
    fetchRecentArtists(category: "SOCIAL_POST");
    //feature artists list
    fetchTopRatedArtistsMethod();
    //suggested for you
    fetchSuggestedArtistsMethod();
    //spotlight section
    fetchSpotlightData();

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

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    String category = "";
    if (index == 0) category = "SOCIAL_POST";
    if (index == 1) category = "REPOST";
    if (index == 2) category = "SERVICE";
    fetchRecentArtists(category: category);
  }

  Future<void> fetchRecentArtists({String? category}) async {
    isLoading(true);
    isError(false);
    errorMessage('');

    try {
      final artists = await service.fetchRecentArtist(category: category);

      recentArtistsList.assignAll(artists);
      debugPrint("Recent artists loaded: ${artists.length} for category: $category");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());

      debugPrint("Error in HomeController: $e");

      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchTopRatedArtistsMethod() async {
    isLoading(true);
    isError(false);
    errorMessage('');

    try {
      final artists = await service.fetchTopRatedArtist();

      topRatedArtistsList.assignAll(artists);
      debugPrint("Toprated artists loaded: ${artists.length}");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());

      debugPrint("Error in HomeController: $e");

      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSuggestedArtistsMethod() async {
    isLoading(true);
    isError(false);
    errorMessage('');

    try {
      final artists = await service.fetchSuggestedArtist();

      suggestedForYouList.assignAll(artists);
      debugPrint("Suggested artists loaded: ${artists.length}");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());

      debugPrint("Error in HomeController: $e");

      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshHomeData() async {
    try {
      isLoading(true);

      String category = "";
      if (selectedCategoryIndex.value == 0) category = "SOCIAL_POST";
      if (selectedCategoryIndex.value == 1) category = "REPOST";
      if (selectedCategoryIndex.value == 2) category = "SERVICE";

      await Future.wait([
        fetchRecentArtists(category: category),
        fetchTopRatedArtistsMethod(),
        fetchSuggestedArtistsMethod(),
      ]);
    } finally {
      isLoading(false);
    }
  }

  Future<bool> sendInquiry({required String userID}) async {
    final url = Uri.parse("${Endpoint.baseUrl}/users/$userID/inquiry");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization":
              await sharedPreferencesHelperController.getAccessToken() != null
              ? "${await sharedPreferencesHelperController.getAccessToken()}"
              : "",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        print("Inquiry Success");
        EasyLoading.showSuccess("Inquiry sent successfully!");
        return true;
      } else {
        EasyLoading.showError("Failed to send inquiry. Please try again.");
        print("Inquiry Failed: ${response.statusCode}${response.body}");
        return false;
      }
    } catch (e) {
      print("Inquire API hit error: $e");
      return false;
    }
  }

  //sptotlight section

  var spotlightList = <SpotlightListingModel>[].obs;
  var isSpotlightLoading = false.obs;

  void fetchSpotlightData() async {
    try {
      isSpotlightLoading(true);
      final listings = await service.fetchSpotlightListings();
      spotlightList.assignAll(listings);
    } catch (e) {
      debugPrint("Error fetching spotlight data: $e");
    } finally {
      isSpotlightLoading(false);
    }
  }
}
