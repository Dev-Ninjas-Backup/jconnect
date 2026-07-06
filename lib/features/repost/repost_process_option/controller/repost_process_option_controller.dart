import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_process_option/api_services/repost_api_pament_service.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';

class RepostProcessOptionController extends GetxController {
  final RepostApiPaymentService _paymentService = RepostApiPaymentService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) print("unauthorized");
      },
    ),
  );

  final platform = Rxn<RepostPlatform>();
  final selectedOptionIndex = 0.obs;

  final paymentIntentId = ''.obs;
  final paymentAmount = 0.obs;
  final paymentCurrency = ''.obs;

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

  Future<Map<String, dynamic>?> processPayment(String listingId) async {
    try {
      EasyLoading.show(status: 'Processing payment...');
      final response = await _paymentService.initiateRepostPayment(listingId);

      paymentIntentId.value = response['paymentIntentId'] as String? ?? '';
      paymentAmount.value = response['amount'] as int? ?? 0;
      paymentCurrency.value = response['currency'] as String? ?? '';

      EasyLoading.dismiss();
      return response;
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  String get selectedTimeframeEnum {
    switch (selectedIndex.value) {
      case 0:
        return 'THIRTY_MIN';
      case 1:
        return 'ONE_HOUR';
      case 2:
        return 'TWO_HOURS';
      case 3:
        return 'SIX_HOURS';
      case 4:
        return 'TWELVE_HOURS';
      case 5:
        return 'TWENTY_FOUR_HOURS';
      default:
        return 'TWO_HOURS';
    }
  }

  Future<bool> createRepostOrder({
    required String listingId,
    required String contentUrl,
    required String paymentIntentId,
    required String timeframe,
  }) async {
    try {
      EasyLoading.show(status: 'Creating order...');
      await _paymentService.createRepostOrder(
        listingId: listingId,
        contentUrl: contentUrl,
        paymentIntentId: paymentIntentId,
        timeframe: timeframe,
      );
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
