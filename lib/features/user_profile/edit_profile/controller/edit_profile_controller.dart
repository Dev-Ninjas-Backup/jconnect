// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';
import 'package:jconnect/features/profile_setup/controller/profile_setup_controller.dart';

class EditProfileController extends GetxController {
  final RxString imagePath = ''.obs;
  final profileRepository = ProfileRepository();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bioController = TextEditingController();
  final aboutInfoController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final RxList<Map<String, TextEditingController>> socialLinks =
      <Map<String, TextEditingController>>[].obs;

  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSocialLinks();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      isLoading.value = true;
      final profileData = await profileRepository.getProfile();

      // Extract user data from response
      final userData = profileData['user'] ?? {};
      final fullName = userData['full_name'] as String? ?? '';
      final email = userData['email'] as String? ?? '';

      // Split full name into first and last name
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Update controllers with fetched data
      firstNameController.text = firstName;
      lastNameController.text = lastName;
      bioController.text = profileData['short_bio'] ?? '';
      emailController.text = email;

      // Populate social links from API response
      _updateSocialLinks(profileData);

      print('DEBUG: Profile data loaded successfully');
    } catch (e) {
      print('DEBUG: Error loading profile data: $e');
      // Initialize with empty values on error
      _initializeEmptyFields();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateSocialLinks(Map<String, dynamic> profileData) {
    socialLinks.clear();

    final platformMap = <int, String>{
      1: 'Instagram',
      2: 'Facebook',
      3: 'TikTok',
      4: 'YouTube',
    };

    // Parse socialProfiles array from API response
    final socialProfilesList = profileData['socialProfiles'] as List? ?? [];
    final socialProfilesMap = <int, String>{};

    for (var profile in socialProfilesList) {
      if (profile is Map<String, dynamic>) {
        final orderId = profile['orderId'] as int?;
        final platformLink = profile['platformLink'] as String? ?? '';
        if (orderId != null) {
          socialProfilesMap[orderId] = platformLink;
        }
      }
    }

    // Initialize all platforms
    for (var entry in platformMap.entries) {
      final orderId = entry.key;
      final platform = entry.value;
      final value = socialProfilesMap[orderId] ?? '';

      socialLinks.add({
        'platform': TextEditingController(text: platform),
        'username': TextEditingController(text: value),
      });
    }
  }

  void _initializeEmptyFields() {
    firstNameController.clear();
    lastNameController.clear();
    bioController.clear();
    emailController.clear();
    aboutInfoController.clear();
  }

  void _initializeSocialLinks() {
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

      // Build social profiles array
      final List<SocialProfile> socialProfilesList = [];
      final platformMap = <String, int>{
        'instagram': 1,
        'facebook': 2,
        'tiktok': 3,
        'youtube': 4,
      };

      for (var link in socialLinks) {
        final platform = link['platform']?.text.toLowerCase() ?? '';
        final username = link['username']?.text ?? '';

        if (username.isNotEmpty) {
          final orderId = platformMap[platform] ?? 0;
          final platformName = link['platform']?.text ?? '';
          
          if (orderId > 0) {
            socialProfilesList.add(
              SocialProfile(
                orderId: orderId,
                platformName: platformName,
                platformLink: username,
              ),
            );
          }
        }
      }

      await profileRepository.updateProfile(
        profileImageUrl: imagePath.value.isNotEmpty ? imagePath.value : null,
        shortBio: bioController.text.isNotEmpty ? bioController.text : null,
        socialProfiles: socialProfilesList,
      );

      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Profile updated successfully!');

      Future.delayed(Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to update profile: $e');
      print('DEBUG: Save profile error: $e');
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    aboutInfoController.dispose();
    emailController.dispose();
    phoneController.dispose();

    for (var link in socialLinks) {
      link['platform']?.dispose();
      link['username']?.dispose();
    }

    super.onClose();
  }
}
