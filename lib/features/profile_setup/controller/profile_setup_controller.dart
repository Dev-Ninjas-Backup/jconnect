// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/edit_profile/model/social_profile_model.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';


class SetUpProfileController extends GetxController {

final pref=Get.find<SharedPreferencesHelperController>();
  final RxString imagePath = ''.obs;
  final RxBool isLoading = false.obs;

  final profileRepository = ProfileRepository();
  final ImagePicker _picker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();

  final RxList<Map<String, TextEditingController>> socialLinks =
      <Map<String, TextEditingController>>[].obs;

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
          socialLinks.add({
            'platform': TextEditingController(text: profile.platformName ?? ''),
            'username': TextEditingController(text: profile.platformLink ?? ''),
          });
        }
      } else {
        // Default empty social links
        socialLinks.value = [
          {
            'platform': TextEditingController(text: 'Instagram'),
            'username': TextEditingController(),
          },
          {
            'platform': TextEditingController(text: 'Facebook'),
            'username': TextEditingController(),
          },
          {
            'platform': TextEditingController(text: 'TikTok'),
            'username': TextEditingController(),
          },
          {
            'platform': TextEditingController(text: 'YouTube'),
            'username': TextEditingController(),
          },
        ];
      }
    } catch (e) {
      print('Error initializing social links: $e');
      // Fallback to default links
      socialLinks.value = [
        {
          'platform': TextEditingController(text: 'Instagram'),
          'username': TextEditingController(),
        },
        {
          'platform': TextEditingController(text: 'Facebook'),
          'username': TextEditingController(),
        },
        {
          'platform': TextEditingController(text: 'TikTok'),
          'username': TextEditingController(),
        },
        {
          'platform': TextEditingController(text: 'YouTube'),
          'username': TextEditingController(),
        },
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
      'platform': TextEditingController(),
      'username': TextEditingController(),
    });
  }

  void removeSocialLink(int index) {
    if (socialLinks.length > 1) {
      socialLinks[index]['platform']?.dispose();
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
        final platform = link['platform']?.text.trim() ?? '';
        final value = link['username']?.text.trim() ?? '';

        // Accept any platform name as long as the username/value is not empty
        if (value.isNotEmpty && platform.isNotEmpty) {
          socialProfiles.add(
            SocialProfile(
              orderId: orderId,
              platformName: platform,
              platformLink: value,
            ),
          );
          orderId++;
        }
      }

      await profileRepository.updateProfile(
        fullName:
           pref.getSavedName().toString(),
        phone:"sss",
        shortBio: bioController.text.trim(),
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
        socialProfiles: socialProfiles,


        
      );
      print("name123:${ pref.getSavedName().toString()}");
            print("phone123:${pref.getPhoneNumber().toString()}");


      EasyLoading.showSuccess('Profile updated successfully');
      Get.back();
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
