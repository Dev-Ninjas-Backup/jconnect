import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_listings/model/repost_listing_model.dart';
import 'package:jconnect/features/repost/repost_listings/service/repost_listing_service.dart';

class RepostListingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final RepostListingService service = RepostListingService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) {
          print("unauthorized");
        }
      },
    ),
  );

  final RxList<RepostListingModel> activeListings = <RepostListingModel>[].obs;
  final RxList<RepostListingModel> inactiveListings = <RepostListingModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchListings();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchListings() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final listings = await service.fetchMyRepostListings();
      activeListings.assignAll(listings.where((l) => l.isActive).toList());
      inactiveListings.assignAll(listings.where((l) => !l.isActive).toList());
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStatus(RepostListingModel item) {
    final updatedItem = RepostListingModel(
      id: item.id,
      sellerId: item.sellerId,
      platform: item.platform,
      price: item.price,
      followerCount: item.followerCount,
      description: item.description,
      isActive: !item.isActive,
      isPaused: item.isPaused,
      isSpotlight: item.isSpotlight,
      defaultTurnaround: item.defaultTurnaround,
      totalPurchases: item.totalPurchases,
      totalAccepts: item.totalAccepts,
      totalProofs: item.totalProofs,
      totalRedos: item.totalRedos,
      totalAutoReleases: item.totalAutoReleases,
      totalCompleted: item.totalCompleted,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );

    if (item.isActive) {
      activeListings.remove(item);
      inactiveListings.add(updatedItem);
    } else {
      inactiveListings.remove(item);
      activeListings.add(updatedItem);
    }
  }
}
