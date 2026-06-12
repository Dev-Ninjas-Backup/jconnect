import 'package:get/get.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';

class RepostProcessOptionController extends GetxController {
  final platform = Rxn<RepostPlatform>();
  final selectedOptionIndex = 0.obs;

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
