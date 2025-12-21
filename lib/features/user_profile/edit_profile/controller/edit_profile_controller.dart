// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';

import '../model/social_profile_model.dart';

class EditProfileController extends GetxController {
  final RxString imagePath = ''.obs;
  final RxBool isLoading = false.obs;

  final profileRepository = ProfileRepository();
  final ImagePicker _picker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bioController = TextEditingController();
  final aboutInfoController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final RxList<Map<String, TextEditingController>> socialLinks =
      <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSocialLinks();
  }

  void _initializeSocialLinks() {
    socialLinks.value = [
      {'platform': TextEditingController(text: 'Instagram'), 'username': TextEditingController()},
      {'platform': TextEditingController(text: 'Facebook'), 'username': TextEditingController()},
      {'platform': TextEditingController(text: 'TikTok'), 'username': TextEditingController()},
      {'platform': TextEditingController(text: 'YouTube'), 'username': TextEditingController()},
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

      final platformOrder = {
        'instagram': 1,
        'facebook': 2,
        'tiktok': 3,
        'youtube': 4,
      };

      final List<SocialProfile> socialProfiles = [];

      for (var link in socialLinks) {
        final platform = link['platform']?.text.trim().toLowerCase() ?? '';
        final value = link['username']?.text.trim() ?? '';

        if (value.isNotEmpty && platformOrder.containsKey(platform)) {
          socialProfiles.add(
            SocialProfile(
              orderId: platformOrder[platform]!,
              platformName: link['platform']!.text,
              platformLink: value,
            ),
          );
        }
      }

      await profileRepository.updateProfile(
        fullName:
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        phone: phoneController.text.trim(),
        shortBio: bioController.text.trim(),
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
        socialProfiles: socialProfiles,
      );

      EasyLoading.showSuccess('Profile updated successfully');
      Get.back();
    } catch (e) {
      EasyLoading.showError(e.toString());
      print(e);
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
