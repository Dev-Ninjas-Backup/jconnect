import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateEditRepostListingController extends GetxController {
  
  final Map<String, List<String>> platformOptions = {
    'Instagram': ['Story Repost', 'Feed Repost', 'Reel Repost'],
    'Tiktok': ['Repost', 'Duet/Stitch Repost'],
    'X': ['Repost', 'Quote Repost'],
    'YouTube': ['Community Post Repost', 'Video Repost (Shorts)'],
    'Facebook': ['Post Repost', 'Story Repost'],
  };

  final Map<String, String> platformApiMap = {
    'Instagram': 'INSTAGRAM',
    'Tiktok': 'TIKTOK',
    'X': 'TWITTER',
    'YouTube': 'YOUTUBE',
    'Facebook': 'FACEBOOK',
  };

  final List<String> turnaroundOptions = [
    'Within 30 Minutes',
    'Within 1 Hour',
    'Within 2 Hours',
    'Within 6 Hours',
    'Within 12 Hours',
    'Within 24 Hours',
  ];

  final RxString selectedPlatform = 'Instagram'.obs;
  final RxString selectedRepostType = 'Story Repost'.obs;
  final RxString selectedTurnaround = 'Within 24 Hours'.obs;
  final RxBool acceptsDollarProgram = true.obs;

  

  final TextEditingController priceController = TextEditingController(
    text: '1.00',
  );
  final TextEditingController descriptionController = TextEditingController();

  final RxInt descriptionLength = 0.obs;
  static const int maxDescriptionLength = 200;

  

  List<String> get repostTypesForSelectedPlatform =>
      platformOptions[selectedPlatform.value] ?? [];

  
  @override
  void onInit() {
    super.onInit();
    descriptionController.addListener(() {
      descriptionLength.value = descriptionController.text.length;
    });
  }

  @override
  void onClose() {
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void onPlatformChanged(String? value) {
    if (value == null) return;
    selectedPlatform.value = value;
    final types = platformOptions[value];
    if (types != null && types.isNotEmpty) {
      selectedRepostType.value = types.first;
    }
  }

  void onRepostTypeChanged(String? value) {
    if (value == null) return;
    selectedRepostType.value = value;
  }

  void onTurnaroundChanged(String? value) {
    if (value == null) return;
    selectedTurnaround.value = value;
  }

  void toggleDollarProgram(bool value) {
    acceptsDollarProgram.value = value;
  }

  void onSave() {
    final platformApi = platformApiMap[selectedPlatform.value];

    debugPrint(
      'Save: platform=$platformApi, '
      'repostType=${selectedRepostType.value}, '
      'price=${priceController.text}, '
      'turnaround=${selectedTurnaround.value}, '
      'acceptsDollar=${acceptsDollarProgram.value}, '
      'description=${descriptionController.text}',
    );
    Get.back();
  }
}
