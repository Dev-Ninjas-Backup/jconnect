// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/edit_profile/model/social_profile_model.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';
import 'package:jconnect/features/user_profile/edit_profile/controller/edit_profile_controller.dart'
    show platformMap;

class SetUpProfileController extends GetxController {
  final pref = Get.find<SharedPreferencesHelperController>();
  final RxString imagePath = ''.obs;
  final RxBool isLoading = false.obs;

  final profileRepository = ProfileRepository();
  final ImagePicker _picker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final hashTageController = TextEditingController();
  final userNameController = TextEditingController();

  final RxList<Map<String, dynamic>> socialLinks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileController = Get.find<ProfileController>();
      final user = profileController.user.value;

      // Parse full name into first and last name
      final fullName = user.fullName ?? user.name;
      final nameParts = fullName.split(' ');

      firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      lastNameController.text = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      bioController.text = user.shortbio;
      phoneController.text = user.phone ?? '';

      // Initialize social links with API data
      _initializeSocialLinks();
    } catch (e) {
      print('Error loading profile data: $e');
      _initializeSocialLinks();
    }
  }

  void _initializeSocialLinks() {
    try {
      final profileController = Get.find<ProfileController>();
      final user = profileController.user.value;

      // Clear existing links
      socialLinks.clear();

      // If user has existing social profiles, populate them
      if (user.socialProfiles != null && user.socialProfiles!.isNotEmpty) {
        for (var profile in user.socialProfiles!) {
          // Extract platform name from the platformLink if it's a URL
          // Otherwise use platformName directly
          String platformName = profile.platformName ?? 'INSTAGRAM';
          String username = profile.platformLink ?? '';

          // If platformLink is a URL, try to extract the username
          if (username.contains('http')) {
            for (var entry in platformMap.entries) {
              if (username.contains(entry.value.baseUrl)) {
                platformName = entry.key;
                username = username
                    .replaceAll(entry.value.baseUrl, '')
                    .replaceAll('@', '');
                break;
              }
            }
          }

          socialLinks.add({
            'selectedPlatform': platformName,
            'username': TextEditingController(text: username),
          });
        }
      } else {
        // Default empty social links
        socialLinks.value = [
          {
            'selectedPlatform': 'INSTAGRAM',
            'username': TextEditingController(),
          },
          {'selectedPlatform': 'FACEBOOK', 'username': TextEditingController()},
          {'selectedPlatform': 'TIKTOK', 'username': TextEditingController()},
          {'selectedPlatform': 'YOUTUBE', 'username': TextEditingController()},
        ];
      }
    } catch (e) {
      print('Error initializing social links: $e');
      // Fallback to default links
      socialLinks.value = [
        {'selectedPlatform': 'INSTAGRAM', 'username': TextEditingController()},
        {'selectedPlatform': 'FACEBOOK', 'username': TextEditingController()},
        {'selectedPlatform': 'TIKTOK', 'username': TextEditingController()},
        {'selectedPlatform': 'YOUTUBE', 'username': TextEditingController()},
      ];
    }
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imagePath.value = picked.path;
    }
  }

  void addSocialLink() {
    socialLinks.add({
      'selectedPlatform': 'INSTAGRAM',
      'username': TextEditingController(),
    });
  }

  void removeSocialLink(int index) {
    if (socialLinks.length > 1) {
      socialLinks[index]['username']?.dispose();
      socialLinks.removeAt(index);
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Updating profile...');

      final List<SocialProfile> socialProfiles = [];
      int orderId = 1;

      for (var link in socialLinks) {
        final platformKey = link['selectedPlatform'] as String? ?? 'INSTAGRAM';
        final value = link['username']?.text.trim() ?? '';

        if (value.isNotEmpty) {
          final platformInfo = platformMap[platformKey];
          final fullUrl = platformInfo != null
              ? '${platformInfo.baseUrl}$value'
              : value;

          socialProfiles.add(
            SocialProfile(
              orderId: orderId,
              platformName: platformKey,
              platformLink: fullUrl,
            ),
          );
          orderId++;
        }
      }

      // Resolve fullName and phone from SharedPreferences with sensible fallbacks
      final String? savedName = await pref.getSavedUserName();
      final String? savedPhone = await pref.getSavedPhoneNumber();
      final profileController = Get.find<ProfileController>();

      final String finalFullName = (savedName != null && savedName.isNotEmpty)
          ? savedName
          : (profileController.user.value.fullName ??
                profileController.user.value.name);

      final String finalPhone = (savedPhone != null && savedPhone.isNotEmpty)
          ? savedPhone
          : (profileController.user.value.phone ?? phoneController.text);

      await profileRepository.updateProfile(
        fullName: finalFullName,
        phone: finalPhone,
        shortBio: bioController.text.trim(),
        location: locationController.text.trim(),
        username: userNameController.text.trim(),
        hashtags: hashTageController.text.trim(),
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
        socialProfiles: socialProfiles,
      );
      print("name123:$finalFullName");
      print("phone123:$finalPhone");

      EasyLoading.showSuccess('Profile updated successfully');
    } catch (e) {
      EasyLoading.showError(e.toString());
      print("Errrrrrrrror $e");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    phoneController.dispose();

    for (var link in socialLinks) {
      link['platform']?.dispose();
      link['username']?.dispose();
    }
    super.onClose();
  }
}
