import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  /// Holds the picked image (nullable)
  final Rxn<XFile> pickedImage = Rxn<XFile>();

  /// Convenience getter to check if an image exists
  bool get hasImage => pickedImage.value != null;

  /// Path of the picked image (or empty)
  String get imagePath => pickedImage.value?.path ?? '';

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
}
