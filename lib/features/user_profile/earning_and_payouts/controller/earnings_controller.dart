import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class EarningsController extends GetxController {
  // Use .obs to make these variables reactive
  var totalEarnings = 0.obs;
  var pendingClearance = 0.obs;
  var availableToWithdraw = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    try {
      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(Endpoint.earnings),
        headers: {
          'Authorization': token, // Add 'Bearer ' if your backend requires it
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> map = json.decode(response.body);
        updateFromApi(map);
      }
    } catch (e) {
      // Error handling logic
    }
  }

  void updateFromApi(Map<String, dynamic> json) {
    totalEarnings.value = (json['totalEarning'] as num?)?.toInt() ?? 0;
    pendingClearance.value = (json['pendingClearance'] as num?)?.toInt() ?? 0;
    availableToWithdraw.value =
        (json['availableBalance'] as num?)?.toInt() ?? 0;
  }

  // Keeping your existing logic for the buttons
  void processWithdrawal(int amount) {
    if (amount <= 0 || amount > availableToWithdraw.value) return;
    availableToWithdraw.value -= amount;
    pendingClearance.value += amount;
  }
}
