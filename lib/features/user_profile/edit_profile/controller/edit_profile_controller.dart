import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';

class EditProfileController extends GetxController {
  final RxString imagePath = ''.obs;
  final profileRepository = ProfileRepository();

  final firstNameController = TextEditingController(text: 'DJ Alex');
  final lastNameController = TextEditingController(text: 'Kinseki');
  final bioController = TextEditingController(
    text: 'DJ + Producer • Passionate about mixing beats and connecting vibes.',
  );
  final aboutInfoController = TextEditingController(
    text:
        'Multi-genre DJ and producer known for blending deep house and electro with cinematic soundscapes. Based in Miami, performing worldwide.',
  );
  final emailController = TextEditingController(text: 'djkinseki@gmail.com');
  final phoneController = TextEditingController(text: '408 555 0120');

  final RxList<Map<String, TextEditingController>> socialLinks =
      <Map<String, TextEditingController>>[].obs;

  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSocialLinks();
  }

  void _initializeSocialLinks() {
    socialLinks.value = [
      {
        'platform': TextEditingController(text: 'Instagram'),
        'username': TextEditingController(text: '@djkinseki56'),
      },
      {
        'platform': TextEditingController(text: 'Facebook'),
        'username': TextEditingController(text: '@djkinseki56'),
      },
      {
        'platform': TextEditingController(text: 'TikTok'),
        'username': TextEditingController(text: '@djkinseki56'),
      },
      {
        'platform': TextEditingController(text: 'YouTube'),
        'username': TextEditingController(text: '@djkinseki56'),
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

      // Extract social media usernames
      String? instagram;
      String? facebook;
      String? tiktok;
      String? youtube;

      for (var link in socialLinks) {
        final platform = link['platform']?.text.toLowerCase() ?? '';
        final username = link['username']?.text ?? '';

        if (username.isNotEmpty) {
          if (platform.contains('instagram')) {
            instagram = username;
          } else if (platform.contains('facebook')) {
            facebook = username;
          } else if (platform.contains('tiktok')) {
            tiktok = username;
          } else if (platform.contains('youtube')) {
            youtube = username;
          }
        }
      }

      await profileRepository.updateProfile(
        profileImageUrl: imagePath.value.isNotEmpty ? imagePath.value : null,
        shortBio: bioController.text.isNotEmpty ? bioController.text : null,
        instagram: instagram,
        facebook: facebook,
        tiktok: tiktok,
        youtube: youtube,
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
