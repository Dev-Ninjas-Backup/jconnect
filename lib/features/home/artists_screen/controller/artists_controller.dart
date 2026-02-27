// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/home/home_screen/services/home_service.dart';

class ArtistsController extends GetxController {
  final HomeService service = HomeService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) {
          print("unauthorized");
        }
      },
    ),
  );

  SharedPreferencesHelperController sharedPreferencesHelperController =
      Get.find<SharedPreferencesHelperController>();

  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var searchTextController = TextEditingController();
  final RxInt selectArtistsItemIndex = 0.obs;
  final artistsItems = <ArtistsModel>[].obs;
  final searchArtistItems = <ArtistsModel>[].obs;

  final RxList<String> artistItemTab = [
    'All Users',
    'Recently Updated',
    'Top Rated',
    'Suggested',
  ].obs;
  @override
  void onInit() {
    fetchAllArtistsMethod();
    super.onInit();
  }

  Future<void> fetchAllArtistsMethod() async {
    isLoading(true);
    isError(false);
    errorMessage('');

    try {
      final artists = await service.fetchAllArtist();

      artistsItems.assignAll(artists);
      debugPrint("All artists loaded: ${artists.length}");
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

  // Future<void> searchArtistByName(String name) async {
  //   isLoading(true);
  //   try {
  //     final result = await service.searchArtist(name);
  //     searchArtistItems.assignAll(result);
  //   } catch (e) {
  //     EasyLoading.showError("Search error: $e");
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<void> searchArtistByName(String name) async {
    if (name.trim().isEmpty) {
      searchArtistItems.clear();
      return;
    }

    isLoading(true);
    try {
      final result = await service.searchArtist(name);
      searchArtistItems.assignAll(result);
    } catch (e) {
      EasyLoading.showError("Search error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> sendInquiry({required String userID}) async {
    final url = Uri.parse("${Endpoint.baseUrl}/users/$userID/inquiry");

    try {
      await http.get(
        url,
        headers: {
          "Authorization":
              "Bearer ${sharedPreferencesHelperController.getAccessRowToken()}",
          "Accept": "application/json",
        },
      );

      // No response handling needed
    } catch (e) {
      print("Inquire API hit error: $e");
    }
  }

  @override
  void onClose() {
    debugPrint("ArtistsController disposed");
    searchTextController.clear();
    searchTextController.dispose();
    searchArtistItems.clear();
    super.onClose();
  }
}
