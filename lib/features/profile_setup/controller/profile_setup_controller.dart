import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import 'package:jconnect/features/user_profile/edit_profile/model/social_profile_model.dart';
import 'package:jconnect/features/user_profile/repository/profile_repository.dart';

// --- MODELS ---

// class SocialProfile {
//   final int orderId;
//   final String platformName;
//   final String platformLink;

//   SocialProfile({
//     required this.orderId,
//     required this.platformName,
//     required this.platformLink,
//   });

//   Map<String, dynamic> toJson() => {
//         'orderId': orderId,
//         'platformName': platformName,
//         'platformLink': platformLink,
//       };
// }

class SocialInput {
  String? selectedPlatform;
  final TextEditingController urlController = TextEditingController();
}

// --- CONTROLLER ---

class ProfileSetupController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final profileRepository = ProfileRepository();

  final Rxn<XFile> pickedImage = Rxn<XFile>();
  bool get hasImage => pickedImage.value != null;
  String get imagePath => pickedImage.value?.path ?? '';

  final bioController = TextEditingController();
  final RxBool isLoading = false.obs;

  // Dynamic list for Social Media Dropdowns
  final RxList<SocialInput> socialInputs = <SocialInput>[
    SocialInput(), // Starts with one field
  ].obs;

  final List<String> availablePlatforms = [
    'Instagram',
    'Facebook',
    'TikTok',
    'YouTube',
    'Twitter',
    'LinkedIn',
  ];

  void addSocialField() {
    socialInputs.add(SocialInput());
  }

  void removeSocialField(int index) {
    if (socialInputs.length > 1) {
      socialInputs.removeAt(index);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) pickedImage.value = image;
    } catch (e) {
      EasyLoading.showError('Failed to pick image');
    }
  }

  void showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createProfile() async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Creating profile...');

      // Build the list for the API
      // final List<SocialProfile> socialProfilesList = socialInputs
      //     .asMap()
      //     .entries
      //     .where(
      //       (e) =>
      //           e.value.selectedPlatform != null &&
      //           e.value.urlController.text.isNotEmpty,
      //     )
      //     .map(
      //       (e) => SocialProfile(
      //         orderId: e.key + 1,
      //         platformName: e.value.selectedPlatform!,
      //         platformLink: e.value.urlController.text.trim(),
      //       ),
      //     )
      //     .toList();

      await profileRepository.createProfile(
        // profile_image_url: imagePath.isNotEmpty ? imagePath : null,
        // shortBio: bioController.text.trim(),
        // socialProfiles: socialProfilesList,
      );

      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.showError('Failed to create profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    bioController.dispose();
    for (var input in socialInputs) {
      input.urlController.dispose();
    }
    super.onClose();
  }
}
