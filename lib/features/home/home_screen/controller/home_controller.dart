import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/services/home_service.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/home/home_screen/model/start_deal_model.dart';

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










}
