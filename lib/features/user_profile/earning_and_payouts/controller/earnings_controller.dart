import 'package:get/get.dart';

class EarningsController extends GetxController {
  var totalEarnings = 1240.obs;
  var pendingClearance = 348.obs;
  var availableToWithdraw = 892.obs;

  /// Process a withdrawal request
  /// Reduces availableToWithdraw and optionally updates pendingClearance
  void processWithdrawal(int amount) {
    if (amount <= 0) return; // ignore invalid amounts
    if (amount > availableToWithdraw.value) {
      // Optional: show error if using a UI layer
      print('Withdrawal amount exceeds available balance');
      return;
    }

    availableToWithdraw.value -= amount;
    pendingClearance.value += amount; // moved to pending
    print('Withdrawal processed: $amount');
  }

  /// Increase available balance (e.g., earnings added)
  void updateBalance(int amount) {
    if (amount <= 0) return;
    availableToWithdraw.value += amount;
    totalEarnings.value += amount;
  }
}
