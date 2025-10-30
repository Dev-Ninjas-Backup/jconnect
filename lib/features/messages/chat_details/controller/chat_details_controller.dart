import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatDetailsController extends GetxController {
  var messages = <String>[].obs;
  var messageController = TextEditingController();
  var showSidebar = false.obs;

  var pickedFile = Rxn<File>();

  final ImagePicker _picker = ImagePicker();

  void sendMessage() {
    if (messageController.text.trim().isNotEmpty) {
      messages.add(messageController.text.trim());
      messageController.clear();
    }
  }

  void toggleSidebar() {
    showSidebar.value = !showSidebar.value;
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedFile.value = File(image.path);
    }
  }
}
