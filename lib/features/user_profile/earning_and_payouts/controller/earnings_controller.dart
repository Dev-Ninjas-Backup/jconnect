import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class EarningsController extends GetxController {
  var totalEarnings = 0.obs;
  var pendingClearance = 0.obs;
  var availableToWithdraw = 0.obs;

  // Observable list for the chart
  var monthlyEarnings = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    try {
      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();

      if (token == null) {
        return;
      }

      final response = await http.get(
        Uri.parse(Endpoint.earnings),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        updateFromApi(data);
      }
    } catch (e) {
      return;
    }
  }

  void updateFromApi(Map<String, dynamic> json) {
    totalEarnings.value = (json['totalEarnings'] as num?)?.toInt() ?? 0;
    pendingClearance.value = (json['pendingClearance'] as num?)?.toInt() ?? 0;
    availableToWithdraw.value =
        (json['availableToWithdraw'] as num?)?.toInt() ?? 0;

    if (json['monthlyEarnings'] != null) {
      // .assignAll is VITAL. It replaces the list AND tells GetX to rebuild the UI.
      monthlyEarnings.assignAll(
        List<Map<String, dynamic>>.from(json['monthlyEarnings']),
      );
    }
  }

  void processWithdrawal(int amount) {
    if (amount <= 0 || amount > availableToWithdraw.value) return;
    availableToWithdraw.value -= amount;
    pendingClearance.value += amount;
  }
}
