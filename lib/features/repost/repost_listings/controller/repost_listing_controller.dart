import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_listings/model/repost_listing_model.dart';
import 'package:jconnect/features/repost/repost_listings/service/repost_listing_service.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';

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
  final RxList<RepostListingModel> inactiveListings =
      <RepostListingModel>[].obs;

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

  Future<void> toggleStatus(RepostListingModel item) async {
    try {
      EasyLoading.show(
        status: item.isActive ? 'Deactivating...' : 'Activating...',
      );
      final updatedItem = await service.toggleActiveRepostListing(
        item.id,
        !item.isActive,
      );

      if (item.isActive) {
        activeListings.remove(item);
        inactiveListings.add(updatedItem);
      } else {
        inactiveListings.remove(item);
        activeListings.add(updatedItem);
      }

      EasyLoading.dismiss();
      showGradientSnackBar(
        title: 'Success',
        message: updatedItem.isActive
            ? 'Listing activated successfully!'
            : 'Listing deactivated successfully!',
      );
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error toggling active status: $e');
      showGradientSnackBar(
        title: 'Error',
        message: 'Failed to toggle active status: $e',
      );
    }
  }

  Future<void> deleteRepostListing(String id) async {
    try {
      EasyLoading.show(status: 'Deleting listing...');
      await service.deleteRepostListing(id);

      // Refresh listings
      await fetchListings();

      // Refresh profile controller
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }

      EasyLoading.dismiss();
      showGradientSnackBar(
        title: 'Success',
        message: 'Listing deleted successfully!',
      );
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error deleting repost listing: $e');
      showGradientSnackBar(
        title: 'Error',
        message: 'Failed to delete listing: $e',
      );
    }
  }
}
