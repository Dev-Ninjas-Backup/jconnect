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
  HomeService service;

  ArtistsController({HomeService? service})
      : service = service ??
            HomeService(
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
  var isAllLoading = false.obs;
  var isRecentLoading = false.obs;
  var isTopRatedLoading = false.obs;
  var isSuggestedLoading = false.obs;
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

  final selectedCategoryIndex = 0.obs;
  var recentArtistsList = <ArtistsModel>[].obs;
  final topRatedArtistsList = <ArtistsModel>[].obs;
  final suggestedForYouList = <ArtistsModel>[].obs;

  static const int pageLimit = 10;

  int allArtistsPage = 1;
  final RxBool hasMoreAll = true.obs;

  int recentArtistsPage = 1;
  final RxBool hasMoreRecent = true.obs;

  int topRatedArtistsPage = 1;
  final RxBool hasMoreTopRated = true.obs;

  int suggestedArtistsPage = 1;
  final RxBool hasMoreSuggested = true.obs;

  int searchArtistsPage = 1;
  final RxBool hasMoreSearch = true.obs;

  final RxBool isLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  String get currentCategoryString {
    if (selectedCategoryIndex.value == 0) return "SOCIAL_POST";
    if (selectedCategoryIndex.value == 1) return "REPOST";
    return "SERVICE";
  }

  @override
  void onInit() {
    scrollController.addListener(_scrollListener);

    fetchAllArtistsMethod(isLoadMore: false);
    fetchRecentArtists(category: "SOCIAL_POST", isLoadMore: false);
    fetchTopRatedArtistsMethod(isLoadMore: false);
    fetchSuggestedArtistsMethod(isLoadMore: false);
    super.onInit();
  }

  void _scrollListener() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      if (maxScroll > 0 && currentScroll >= maxScroll - 250) {
        loadMore();
      }
    }
  }

  void loadMore() {
    if (isLoadingMore.value || isLoading.value) return;

    final isSearchActive = searchTextController.text.trim().isNotEmpty;
    if (isSearchActive) {
      if (hasMoreSearch.value) {
        searchArtistByName(searchTextController.text.trim(), isLoadMore: true);
      }
      return;
    }

    if (selectArtistsItemIndex.value == 0) {
      if (hasMoreAll.value) {
        fetchAllArtistsMethod(isLoadMore: true);
      }
    } else if (selectArtistsItemIndex.value == 1) {
      if (hasMoreRecent.value) {
        fetchRecentArtists(category: currentCategoryString, isLoadMore: true);
      }
    } else if (selectArtistsItemIndex.value == 2) {
      if (hasMoreTopRated.value) {
        fetchTopRatedArtistsMethod(isLoadMore: true);
      }
    } else if (selectArtistsItemIndex.value == 3) {
      if (hasMoreSuggested.value) {
        fetchSuggestedArtistsMethod(isLoadMore: true);
      }
    }
  }

  bool _determineHasMore(List<ArtistsModel> artists) {
    if (artists is PaginatedList<ArtistsModel> && artists.hasMore != null) {
      return artists.hasMore!;
    }
    return artists.length >= pageLimit;
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    fetchRecentArtists(category: currentCategoryString, isLoadMore: false);
  }

  Future<void> fetchRecentArtists({String? category, bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore.value || !hasMoreRecent.value) return;
      isLoadingMore(true);
      final nextPage = recentArtistsPage + 1;
      try {
        final artists = await service.fetchRecentArtist(
          category: category ?? currentCategoryString,
          page: nextPage,
          limit: pageLimit,
        );
        recentArtistsPage = nextPage;
        recentArtistsList.addAll(artists);
        hasMoreRecent.value = _determineHasMore(artists);
        debugPrint("Recent artists page $nextPage loaded: ${artists.length}");
      } catch (e) {
        debugPrint("Error loading more recent artists: $e");
      } finally {
        isLoadingMore(false);
      }
      return;
    }

    isRecentLoading(true);
    isLoading(true);
    isError(false);
    errorMessage('');
    recentArtistsPage = 1;
    hasMoreRecent.value = true;

    try {
      final artists = await service.fetchRecentArtist(
        category: category ?? currentCategoryString,
        page: 1,
        limit: pageLimit,
      );

      recentArtistsList.assignAll(artists);
      hasMoreRecent.value = _determineHasMore(artists);
      debugPrint("Recent artists initial loaded: ${artists.length} for category: $category");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
      debugPrint("Error in ArtistsController: $e");
      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isRecentLoading(false);
      isLoading(false);
    }
  }

  Future<void> fetchTopRatedArtistsMethod({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore.value || !hasMoreTopRated.value) return;
      isLoadingMore(true);
      final nextPage = topRatedArtistsPage + 1;
      try {
        final artists = await service.fetchTopRatedArtist(
          page: nextPage,
          limit: pageLimit,
        );
        topRatedArtistsPage = nextPage;
        topRatedArtistsList.addAll(artists);
        hasMoreTopRated.value = _determineHasMore(artists);
        debugPrint("TopRated artists page $nextPage loaded: ${artists.length}");
      } catch (e) {
        debugPrint("Error loading more top rated artists: $e");
      } finally {
        isLoadingMore(false);
      }
      return;
    }

    isTopRatedLoading(true);
    isLoading(true);
    isError(false);
    errorMessage('');
    topRatedArtistsPage = 1;
    hasMoreTopRated.value = true;

    try {
      final artists = await service.fetchTopRatedArtist(
        page: 1,
        limit: pageLimit,
      );

      topRatedArtistsList.assignAll(artists);
      hasMoreTopRated.value = _determineHasMore(artists);
      debugPrint("Toprated artists loaded: ${artists.length}");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
      debugPrint("Error in ArtistsController: $e");
      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isTopRatedLoading(false);
      isLoading(false);
    }
  }

  Future<void> fetchSuggestedArtistsMethod({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore.value || !hasMoreSuggested.value) return;
      isLoadingMore(true);
      final nextPage = suggestedArtistsPage + 1;
      try {
        final artists = await service.fetchSuggestedArtist(
          page: nextPage,
          limit: pageLimit,
        );
        suggestedArtistsPage = nextPage;
        suggestedForYouList.addAll(artists);
        hasMoreSuggested.value = _determineHasMore(artists);
        debugPrint("Suggested artists page $nextPage loaded: ${artists.length}");
      } catch (e) {
        debugPrint("Error loading more suggested artists: $e");
      } finally {
        isLoadingMore(false);
      }
      return;
    }

    isSuggestedLoading(true);
    isLoading(true);
    isError(false);
    errorMessage('');
    suggestedArtistsPage = 1;
    hasMoreSuggested.value = true;

    try {
      final artists = await service.fetchSuggestedArtist(
        page: 1,
        limit: pageLimit,
      );

      suggestedForYouList.assignAll(artists);
      hasMoreSuggested.value = _determineHasMore(artists);
      debugPrint("Suggested artists loaded: ${artists.length}");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
      debugPrint("Error in ArtistsController: $e");
      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isSuggestedLoading(false);
      isLoading(false);
    }
  }

  Future<void> fetchAllArtistsMethod({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore.value || !hasMoreAll.value) return;
      isLoadingMore(true);
      final nextPage = allArtistsPage + 1;
      try {
        final artists = await service.fetchAllArtist(
          page: nextPage,
          limit: pageLimit,
        );
        allArtistsPage = nextPage;
        artistsItems.addAll(artists);
        hasMoreAll.value = _determineHasMore(artists);
        debugPrint("All artists page $nextPage loaded: ${artists.length}");
      } catch (e) {
        debugPrint("Error loading more all artists: $e");
      } finally {
        isLoadingMore(false);
      }
      return;
    }

    isAllLoading(true);
    isLoading(true);
    isError(false);
    errorMessage('');
    allArtistsPage = 1;
    hasMoreAll.value = true;

    try {
      final artists = await service.fetchAllArtist(
        page: 1,
        limit: pageLimit,
      );

      artistsItems.assignAll(artists);
      hasMoreAll.value = _determineHasMore(artists);
      debugPrint("All artists initial loaded: ${artists.length}");
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
      debugPrint("Error in HomeController: $e");
      EasyLoading.showError(
        "Oops! ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      isAllLoading(false);
      isLoading(false);
    }
  }

  void clearSearch() {
    searchTextController.clear();
    searchArtistItems.clear();
    searchArtistsPage = 1;
    hasMoreSearch.value = true;
  }

  Future<void> searchArtistByName(String name, {bool isLoadMore = false}) async {
    if (name.trim().isEmpty) {
      clearSearch();
      return;
    }

    if (isLoadMore) {
      if (isLoadingMore.value || !hasMoreSearch.value) return;
      isLoadingMore(true);
      final nextPage = searchArtistsPage + 1;
      try {
        final result = await service.searchArtist(
          name.trim(),
          page: nextPage,
          limit: pageLimit,
        );
        searchArtistsPage = nextPage;
        searchArtistItems.addAll(result);
        hasMoreSearch.value = _determineHasMore(result);
      } catch (e) {
        debugPrint("Error loading more search artists: $e");
      } finally {
        isLoadingMore(false);
      }
      return;
    }

    isLoading(true);
    searchArtistsPage = 1;
    hasMoreSearch.value = true;
    try {
      final result = await service.searchArtist(
        name.trim(),
        page: 1,
        limit: pageLimit,
      );
      searchArtistItems.assignAll(result);
      hasMoreSearch.value = _determineHasMore(result);
    } catch (e) {
      EasyLoading.showError("Search error: $e");
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
      EasyLoading.showError("Error: ${e.toString()}");
      return false;
    }
  }

  @override
  void onClose() {
    debugPrint("ArtistsController disposed");
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchArtistItems.clear();
    super.onClose();
  }
}
