// ignore_for_file: avoid_print, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/add_services/repository/add_service_repository.dart';

class AddServiceController extends GetxController {
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final followerCountController = TextEditingController();
  final repostPrice = TextEditingController();
  final isSpotlight = RxnBool();
  final RxnString selectedServiceType = RxnString();
  final RxnString selectedSocialPlatform = RxnString();
  final RxnString selectedTurnaround = RxnString();

  var services = <Map<String, dynamic>>[].obs;

  RxnInt editingIndex = RxnInt();

  final AddServiceRepository repository = AddServiceRepository();

  @override
  void onInit() {
    super.onInit();
    fetchServicesFromProfile();
  }

  @override
  void onClose() {
    serviceNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    followerCountController.dispose();
    repostPrice.dispose();
    super.onClose();
  }

  /// FETCH SERVICES
  Future<void> fetchServicesFromProfile() async {
    try {
      EasyLoading.show(status: 'Loading services...');
      final response = await repository.fetchMyProfile();
      EasyLoading.dismiss();

      if (response['services'] is List) {
        services.assignAll(
          (response['services'] as List).map((svc) {
            return {
              'id': svc['id'],
              'name': svc['serviceName'],
              'desc': svc['description'],
              'price': svc['price'],
              'serviceType': svc['serviceType'],
              'isCustom': svc['isCustom'] ?? false,
            };
          }).toList(),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        'Failed to load services',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// ADD OR UPDATE SERVICE
  Future<void> saveService() async {
    final priceValue = double.tryParse(priceController.text) ?? 0.00;

    try {
      EasyLoading.show(
        status: editingIndex.value != null
            ? 'Updating service...'
            : 'Saving service...',
      );

      Map<String, dynamic> response;

      final isSocial = selectedServiceType.value == 'SOCIAL_POST';

      if (selectedServiceType.value == null) {
        EasyLoading.dismiss();
        Get.snackbar('Error', 'Please select a service type.');
        return;
      }

      if (isSocial && selectedSocialPlatform.value == null) {
        EasyLoading.dismiss();
        Get.snackbar('Error', 'Please select a social platform.');
        return;
      }

      if (editingIndex.value != null) {
        // UPDATE SERVICE
        final index = editingIndex.value!;
        final service = services[index];

        response = await repository.updateService(
          id: service['id'],
          serviceName: serviceNameController.text.trim(),
          serviceType: selectedServiceType.value!,
          description: descriptionController.text.trim(),
          price: priceValue.toString(),
          logoAssetPath: isSocial ? selectedLogoPath.value : null,
          socialPlatform: isSocial ? selectedSocialPlatform.value : null,
        );

        print("update service response: $response");

        final updatedSvc = response['service'];
        services[index] = {
          'id': updatedSvc['id'],
          'name': updatedSvc['serviceName'],
          'desc': updatedSvc['description'],
          'price': updatedSvc['price'],
          'serviceType': updatedSvc['serviceType'],
        };
      } else {
        // ADD NEW SERVICE
        response = await repository.createService(
          serviceName: serviceNameController.text.trim(),
          serviceType: selectedServiceType.value!,
          description: descriptionController.text.trim(),
          price: priceValue.toString(),
          logoAssetPath: isSocial ? selectedLogoPath.value : null,
          socialPlatform: isSocial ? selectedSocialPlatform.value : null,
        );
        print("serddddddvice response: $response");

        final svc = response['service'];
        services.add({
          'id': svc['id'],
          'name': svc['serviceName'],
          'desc': svc['description'],
          'price': svc['price'],
          'serviceType': svc['serviceType'],
        });
        print("service response: $svc");
      }

      EasyLoading.dismiss();
      clearForm();
    } catch (e) {
      EasyLoading.dismiss();
      print('Error saving service: $e');
      Get.snackbar(
        'Error',
        editingIndex.value != null
            ? 'Failed to update service'
            : 'Failed to add service',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> saveRepost() async {
    if (selectedSocialPlatform.value == null) {
      Get.snackbar(
        'Error',
        'Please select a social platform.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final priceValue = int.tryParse(repostPrice.text);
    if (priceValue == null) {
      Get.snackbar(
        'Error',
        'Please enter a valid price.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final followerCountValue = int.tryParse(followerCountController.text);
    if (followerCountValue == null) {
      Get.snackbar(
        'Error',
        'Please enter a valid follower count.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final turnaround = selectedTurnaround.value ?? 'TWENTY_FOUR_HOURS';
    final description = descriptionController.text.trim();

    try {
      EasyLoading.show(status: 'Saving repost...');

      final response = await repository.createRepostListing(
        platform: selectedSocialPlatform.value!,
        price: priceValue,
        followerCount: followerCountValue,
        description: description.isNotEmpty
            ? description
            : "I will repost your content on my platform",
        defaultTurnaround: turnaround,
        isSpotlight: isSpotlight.value ?? false,
      );

      print("repost listing save response: $response");
      EasyLoading.dismiss();
      clearForm();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      print('Error saving repost listing: $e');
      Get.snackbar(
        'Error',
        'Failed to save repost listing: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// DELETE SERVICE
  Future<void> deleteService(int index) async {
    final removedService = services[index];
    final serviceId = removedService['id'];

    services.removeAt(index);

    try {
      EasyLoading.show(status: 'Deleting service...');
      await repository.deleteService(serviceId);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      services.insert(index, removedService);
      Get.snackbar(
        'Error',
        'Failed to delete service',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// START EDITING SERVICE
  void startEditingService(int index) {
    // ✅ ADDED
    final svc = services[index];
    serviceNameController.text = svc['name'];
    descriptionController.text = svc['desc'];
    priceController.text = svc['price'].toString();

    final serviceType = svc['serviceType'];
    final socialPlatforms = SocialServiceType.values
        .map((e) => e.name)
        .toList();

    if (socialPlatforms.contains(serviceType)) {
      isSocialService.value = true;
      selectedServiceType.value = 'SOCIAL_POST';
      onSocialPlatformChanged(serviceType);
    } else {
      isSocialService.value = false;
      selectedServiceType.value = serviceType;
      selectedSocialPlatform.value = null;
    }

    editingIndex.value = index;
  }

  /// CLEAR FORM
  void clearForm() {
    // ✅ CHANGED
    serviceNameController.clear();
    descriptionController.clear();
    priceController.clear();
    followerCountController.clear();
    repostPrice.clear();
    isSpotlight.value = null;
    selectedServiceType.value = null;
    selectedSocialPlatform.value = null;
    selectedTurnaround.value = 'TWENTY_FOUR_HOURS';
    isSocialService.value = false;
    selectedLogoPath.value = '';
    editingIndex.value = null;
  }

  RxBool isSocialService = false.obs;
  RxString selectedLogoPath = ''.obs;

  void onServiceTypeChanged(String? value) {
    selectedServiceType.value = value;
    if (value == 'SOCIAL_POST') {
      isSocialService.value = true;
    } else {
      isSocialService.value = false;
      selectedSocialPlatform.value = null;
      selectedLogoPath.value = '';
    }
  }

  void onSocialPlatformChanged(String? value) {
    selectedSocialPlatform.value = value;
    if (value != null) {
      final matchingType = SocialServiceType.values.firstWhere(
        (e) => value.startsWith(e.name),
        orElse: () => SocialServiceType.INSTAGRAM,
      );
      selectedLogoPath.value = matchingType.assetPath;
    } else {
      selectedLogoPath.value = '';
    }
  }
}

enum SocialServiceType {
  FACEBOOK,
  INSTAGRAM,
  TWITTER,
  TIKTOK,
  LINKEDIN,
  YOUTUBE,
  SNAPCHAT,
  TWITCH,
}

extension SocialServiceTypeX on SocialServiceType {
  String get name => toString().split('.').last;

  String get assetPath {
    switch (this) {
      case SocialServiceType.FACEBOOK:
        return Iconpath.facebook;
      case SocialServiceType.INSTAGRAM:
        return Iconpath.instagram;
      case SocialServiceType.TWITTER:
        return Iconpath.twitter;
      case SocialServiceType.TIKTOK:
        return Iconpath.tiktok;
      case SocialServiceType.LINKEDIN:
        return Iconpath.linkedIn;
      case SocialServiceType.YOUTUBE:
        return Iconpath.youtube;
      case SocialServiceType.SNAPCHAT:
        return Iconpath.snapChat;
      case SocialServiceType.TWITCH:
        return Iconpath.twitch;
    }
  }
}
