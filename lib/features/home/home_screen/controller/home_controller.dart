// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/services/home_service.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/home/home_screen/model/start_deal_model.dart';

import '../model/spotligt_model.dart';

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

  // Your list of artists
  var recentArtistsList = <ArtistsModel>[].obs;
  final topRatedArtistsList = <ArtistsModel>[].obs;
  final suggestedForYouList = <ArtistsModel>[].obs;
  @override
  void onInit() {
    //start deal list
    startDealListItem();
    // artists list
    fetchRecentArtists();
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

  Future<void> fetchRecentArtists() async {
    isLoading(true);
    isError(false);
    errorMessage('');

    try {
      final artists = await service.fetchRecentArtist();

      recentArtistsList.assignAll(artists);
      debugPrint("Recent artists loaded: ${artists.length}");
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

      await Future.wait([
        fetchRecentArtists(),
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

  var spotlightList = <SpotlightModel>[].obs;
  var isSpotlightLoading = false.obs;

  void fetchSpotlightData() async {
    try {
      isSpotlightLoading(true);
      await Future.delayed(const Duration(milliseconds: 500));

      var mockData = [
        SpotlightModel(name: "iamkayla", followers: "45K", platform: Icons.facebook, avatarUrl: Imagepath.profileImage, isVerified: true),
        SpotlightModel(name: "jayshotit", followers: "38K", platform: Icons.tiktok, avatarUrl: Imagepath.profileImage, isVerified: null),
        SpotlightModel(name: "theyluvniya", followers: null, platform: Icons.tiktok, avatarUrl: Imagepath.profileImage, isVerified: true),
        SpotlightModel(name: null, followers: "17K", platform: Icons.tiktok, avatarUrl: Imagepath.profileImage, isVerified: false),
        SpotlightModel(name: "prodbyluke", followers: "31K", platform: Icons.facebook, avatarUrl: Imagepath.profileImage, isVerified: true),
      ];

      spotlightList.assignAll(mockData);
    } finally {
      isSpotlightLoading(false);
    }
  }

}
