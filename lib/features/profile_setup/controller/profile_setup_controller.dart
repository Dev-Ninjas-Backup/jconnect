import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ProfileSetupController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final Rxn<XFile> pickedImage = Rxn<XFile>();
  bool get hasImage => pickedImage.value != null;
  String get imagePath => pickedImage.value?.path ?? '';

  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final tiktokController = TextEditingController();
  final youtubeController = TextEditingController();

  bool get hasAnyLink {
    return instagramController.text.trim().isNotEmpty ||
        facebookController.text.trim().isNotEmpty ||
        tiktokController.text.trim().isNotEmpty ||
        youtubeController.text.trim().isNotEmpty;
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

  // bool _isValidLink(String link) {
  //   // Check if the link contains a common domain pattern
  //   final validPatterns = [
  //     '.com',
  //     '.net',
  //     '.org',
  //     '.mail',
  //     '.io',
  //     '.app',
  //     '.co',
  //   ];
  //   return validPatterns.any((pattern) => link.toLowerCase().contains(pattern));
  // }

  // bool get hasAnyValidLink {
  //   return _isValidLink(instagramController.text.trim()) ||
  //       _isValidLink(facebookController.text.trim()) ||
  //       _isValidLink(tiktokController.text.trim()) ||
  //       _isValidLink(youtubeController.text.trim());
  // }

  // bool validateBeforeContinue() {
  //   if (!hasAnyValidLink) {
  //     EasyLoading.showInfo(
  //       'Please add at least one valid social link (like .com, .mail)',
  //     );
  //     return false;
  //   }
  //   return true;
  // }
  @override
  void onClose() {
    instagramController.dispose();
    facebookController.dispose();
    tiktokController.dispose();
    youtubeController.dispose();
    super.onClose();
  }
}
