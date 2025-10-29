import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDetailsController extends GetxController {
  var messages = <String>[].obs;
  var messageController = TextEditingController();
  var showSidebar = false.obs;

  void sendMessage() {
    if (messageController.text.trim().isNotEmpty) {
      messages.add(messageController.text.trim());
      messageController.clear();
    }
  }

  void toggleSidebar() {
    showSidebar.value = !showSidebar.value;
  }
}
