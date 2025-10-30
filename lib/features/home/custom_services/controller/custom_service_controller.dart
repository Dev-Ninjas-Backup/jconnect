
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

class CustomServiceController extends GetxController {
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController platformNameController = TextEditingController();
  final TextEditingController artistsNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController spacialNoteController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }



}
