import 'package:get/get.dart';

class EarningsController extends GetxController {
  var totalEarnings = 1240.obs;
  var pendingClearance = 348.obs;
  var availableToWithdraw = 892.obs;

  void updateBalance(int amount) {
    availableToWithdraw.value += amount;
  }
}
