import 'package:get/get.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';

class RepostProcessOptionController extends GetxController {
  final platform = Rxn<RepostPlatform>();
  final selectedOptionIndex = 0.obs;

  final List<String> timeframes = [
    '30 Minutes',
    '1 Hour',
    '2 Hours',
    '6 Hours',
    '12 Hours',
    '24 Hours',
  ];

  // Default selection: 2 Hours (index 2)
  final selectedIndex = 2.obs;

  void selectTimeframe(int index) {
    selectedIndex.value = index;
  }

  String get selectedTimeframe => timeframes[selectedIndex.value];

  RepostPlatform get currentPlatform {
    final value = platform.value;
    if (value == null) {
      throw StateError('Repost platform is missing');
    }
    return value;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RepostPlatform) {
      platform.value = args;
    } else if (args is Map && args['platform'] is RepostPlatform) {
      platform.value = args['platform'] as RepostPlatform;
    }
  }

  void selectOption(int index) {
    if (index < 0 || index >= currentPlatform.repostOptions.length) return;
    selectedOptionIndex.value = index;
  }
}
