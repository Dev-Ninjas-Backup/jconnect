// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';

class SocialProfile {
  final int orderId;
  final String platformName;
  final String platformLink;

  SocialProfile({
    required this.orderId,
    required this.platformName,
    required this.platformLink,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'platformName': platformName,
      'platformLink': platformLink,
    };
  }
}

class ProfileSetupController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final profileRepository = ProfileRepository();

  final Rxn<XFile> pickedImage = Rxn<XFile>();
  bool get hasImage => pickedImage.value != null;
  String get imagePath => pickedImage.value?.path ?? '';

  final bioController = TextEditingController();
  
  // Social profiles with platform names and order
  final socialProfiles = <int, TextEditingController>{
    1: TextEditingController(), // Instagram
    2: TextEditingController(), // Facebook
    3: TextEditingController(), // TikTok
    4: TextEditingController(), // YouTube
  };

  final socialPlatforms = <int, String>{
    1: 'Instagram',
    2: 'Facebook',
    3: 'TikTok',
    4: 'YouTube',
  };

  final RxBool isLoading = false.obs;

  bool get hasAnyLink {
    return socialProfiles.values.any((controller) => controller.text.trim().isNotEmpty);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        pickedImage.value = image;
      }
    } catch (e) {
      EasyLoading.showError('Failed to pick image');
      rethrow;
    }
  }

  void showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 300));
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 300));
                  pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void clearImage() {
    pickedImage.value = null;
  }

  List<SocialProfile> _buildSocialProfilesArray() {
    List<SocialProfile> profiles = [];
    
    socialProfiles.forEach((orderId, controller) {
      if (controller.text.trim().isNotEmpty) {
        profiles.add(
          SocialProfile(
            orderId: orderId,
            platformName: socialPlatforms[orderId] ?? '',
            platformLink: controller.text.trim(),
          ),
        );
      }
    });
    
    return profiles;
  }

  Future<bool> createProfile() async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Creating profile...');

      final socialProfilesList = _buildSocialProfilesArray();

      await profileRepository.createProfile(
        profileImageUrl: imagePath.isNotEmpty ? imagePath : null,
        shortBio: bioController.text.isNotEmpty ? bioController.text : null,
        socialProfiles: socialProfilesList,
      );

      isLoading.value = false;
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to create profile: $e');
      print('DEBUG: Create profile error: $e');
      return false;
    }
  }

  @override
  void onClose() {
    bioController.dispose();
    socialProfiles.forEach((_, controller) => controller.dispose());
    super.onClose();
  }
}
