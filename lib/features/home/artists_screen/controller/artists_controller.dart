import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
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

  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var searchTextController = TextEditingController();
  final RxInt selectArtistsItemIndex = 0.obs;
  final artistsItems = <ArtistsModel>[].obs;
  final searchArtistItems = <ArtistsModel>[].obs;

  final RxList<String> artistItemTab = [
    'All Artists',
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

  Future<void> searchArtistByName(String name) async {
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
}
