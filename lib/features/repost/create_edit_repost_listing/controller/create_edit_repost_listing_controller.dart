import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/add_services/repository/add_service_repository.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';

class CreateEditRepostListingController extends GetxController {
  final Map<String, String> platformApiMap = {
    'Instagram Story Repost': 'INSTAGRAM_STORY',
    'Instagram Feed Repost': 'INSTAGRAM_FEED',
    'Instagram Reel Repost': 'INSTAGRAM_REEL',
    'Tiktok Repost': 'TIKTOK',
    'Tiktok Duet/Stitch Repost': 'TIKTOK_DUET',
    'X Repost': 'TWITTER',
    'X Quote Repost': 'TWITTER_QUOTE',
    'YouTube Community Post Repost': 'YOUTUBE_COMMUNITY_POST',
    'YouTube Video Repost (Shorts)': 'YOUTUBE_SHORTS',
    'Facebook Post Repost': 'FACEBOOK_POST',
    'Facebook Story Repost': 'FACEBOOK_STORY',
  };

  final Map<String, String> turnaroundOptions = {
    'Within 30 Minutes': "THIRTY_MIN",
    'Within 1 Hour': "ONE_HOUR",
    'Within 2 Hours': "TWO_HOURS",
    'Within 6 Hours': "SIX_HOURS",
    'Within 12 Hours': "TWELVE_HOURS",
    'Within 24 Hours': "TWENTY_FOUR_HOURS",
  };

  final RxString selectedPlatform = 'Instagram Story Repost'.obs;
  final RxString selectedTurnaround = 'Within 24 Hours'.obs;
  final RxBool acceptsDollarProgram = true.obs;

  final TextEditingController priceController = TextEditingController(
    text: '1.00',
  );
  final TextEditingController platformFollowerController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final RxInt descriptionLength = 0.obs;
  static const int maxDescriptionLength = 200;

  final AddServiceRepository repository = AddServiceRepository();

  String? editingListingId;
  final RxBool isFetchingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    descriptionController.addListener(() {
      descriptionLength.value = descriptionController.text.length;
    });

    if (Get.arguments != null && Get.arguments is String) {
      editingListingId = Get.arguments as String;
      fetchListingDetails(editingListingId!);
    }
  }

  @override
  void onClose() {
    priceController.dispose();
    platformFollowerController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchListingDetails(String id) async {
    isFetchingDetails.value = true;
    try {
      final data = await repository.fetchRepostListingById(id);

      final apiPlatform = data['platform'] as String?;
      if (apiPlatform != null) {
        String? displayPlatform;
        for (var entry in platformApiMap.entries) {
          if (entry.value == apiPlatform) {
            displayPlatform = entry.key;
            break;
          }
        }
        if (displayPlatform != null) {
          selectedPlatform.value = displayPlatform;
        }
      }

      final apiTurnaround = data['defaultTurnaround'] as String?;
      if (apiTurnaround != null) {
        String? displayTurnaround;
        for (var entry in turnaroundOptions.entries) {
          if (entry.value == apiTurnaround) {
            displayTurnaround = entry.key;
            break;
          }
        }
        if (displayTurnaround != null) {
          selectedTurnaround.value = displayTurnaround;
        }
      }

      priceController.text = (data['price'] ?? '').toString();
      platformFollowerController.text = (data['followerCount'] ?? '')
          .toString();
      acceptsDollarProgram.value = data['isSpotlight'] ?? false;
      descriptionController.text = data['description'] ?? '';
    } catch (e) {
      debugPrint('Error fetching listing details: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch listing details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isFetchingDetails.value = false;
    }
  }

  void onPlatformChanged(String? value) {
    if (value == null) return;
    selectedPlatform.value = value;
  }

  void onTurnaroundChanged(String? value) {
    if (value == null) return;
    selectedTurnaround.value = value;
  }

  void toggleDollarProgram(bool value) {
    acceptsDollarProgram.value = value;
  }

  Future<void> onSave() async {
    final platformApi = platformApiMap[selectedPlatform.value];
    if (platformApi == null) {
      Get.snackbar(
        'Error',
        'Please select a social platform.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final turnaroundApi = turnaroundOptions[selectedTurnaround.value];
    if (turnaroundApi == null) {
      Get.snackbar(
        'Error',
        'Please select a turnaround time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double? parsedPrice = double.tryParse(priceController.text);
    final int? priceValue = parsedPrice?.round();
    if (priceValue == null) {
      Get.snackbar(
        'Error',
        'Please enter a valid price.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final int? followerCountValue = int.tryParse(
      platformFollowerController.text,
    );
    if (followerCountValue == null) {
      Get.snackbar(
        'Error',
        'Please enter a valid follower count.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final description = descriptionController.text.trim();

    try {
      EasyLoading.show(
        status: editingListingId != null
            ? 'Updating repost...'
            : 'Saving repost...',
      );

      final dynamic response;
      if (editingListingId != null) {
        response = await repository.updateRepostListing(
          id: editingListingId!,
          platform: platformApi,
          price: priceValue,
          followerCount: followerCountValue,
          description: description.isNotEmpty
              ? description
              : "I will repost your content on my platform",
          defaultTurnaround: turnaroundApi,
          isSpotlight: acceptsDollarProgram.value,
        );
      } else {
        response = await repository.createRepostListing(
          platform: platformApi,
          price: priceValue,
          followerCount: followerCountValue,
          description: description.isNotEmpty
              ? description
              : "I will repost your content on my platform",
          defaultTurnaround: turnaroundApi,
          isSpotlight: acceptsDollarProgram.value,
        );
      }

      debugPrint("repost listing save response: $response");
      EasyLoading.dismiss();

      Get.back();
      Get.snackbar(
        'Success',
        editingListingId != null
            ? 'Repost listing updated successfully!'
            : 'Repost listing saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error saving repost listing: $e');
      Get.snackbar(
        'Error',
        'Failed to save repost listing: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
