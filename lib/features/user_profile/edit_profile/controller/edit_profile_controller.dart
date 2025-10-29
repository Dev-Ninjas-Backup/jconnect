import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final RxString imagePath = ''.obs;

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

  final RxList<Map<String, String>> socialLinks = <Map<String, String>>[
    {'platform': 'Instagram', 'username': '@djkinseki56'},
    {'platform': 'Facebook', 'username': '@djkinseki56'},
    {'platform': 'TikTok', 'username': '@djkinseki56'},
    {'platform': 'YouTube', 'username': '@djkinseki56'},
  ].obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imagePath.value = picked.path;
    }
  }

  void addSocialLink() {
    socialLinks.add({'platform': '', 'username': ''});
  }

  void removeSocialLink(int index) {
    if (socialLinks.length > 1) {
      socialLinks.removeAt(index);
    }
  }

  void saveProfile() {
    Get.snackbar(
      'Success',
      'Profile changes saved!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
