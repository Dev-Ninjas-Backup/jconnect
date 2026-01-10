// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/profile/controller/profile_controller.dart';

class EarningsController extends GetxController {
  var totalEarnings = 0.00.obs;
  var pendingClearance = 0.00.obs;
  var availableToWithdraw = 0.00.obs;
  final prefs = SharedPreferencesHelperController();

  // Observable list for the chart
  var monthlyEarnings = <Map<String, dynamic>>[].obs;
  // Withdrawal history fetched from backend
  var withdrawalHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
    fetchWithdrawalHistory();
  }

  /// Fetch the user's withdrawal history from the backend and populate
  /// [withdrawalHistory]. Returns true on success.
  Future<bool> fetchWithdrawalHistory() async {
    try {
      final token = await prefs.getAccessToken();

      if (token == null || token.isEmpty) return false;

      final resp = await http.get(
        Uri.parse(Endpoint.withdrawalHistory),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      print('🔔 [WITHDRAW_HISTORY] status: ${resp.statusCode}');
      print('🔔 [WITHDRAW_HISTORY] body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        withdrawalHistory.assignAll(
          data.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
        return true;
      }

      return false;
    } catch (e, st) {
      print('🔔 [WITHDRAW_HISTORY] fetch error: $e\n$st');
      return false;
    }
  }

  Future<void> fetchEarnings() async {
    try {
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
    totalEarnings.value = (json['totalEarnings'] as num?)?.toDouble() ?? 0.00;
    pendingClearance.value =
        (json['pendingClearance'] as num?)?.toDouble() ?? 0.00;
    availableToWithdraw.value =
        (json['availableToWithdraw'] as num?)?.toDouble() ?? 0.00;

    if (json['monthlyEarnings'] != null) {
      // .assignAll is VITAL. It replaces the list AND tells GetX to rebuild the UI.
      monthlyEarnings.assignAll(
        List<Map<String, dynamic>>.from(json['monthlyEarnings']),
      );
    }
  }

  /// Request a withdrawal from the backend and update local state on success.
  /// Returns true when the request was successful.
  Future<bool> processWithdrawal(int amount) async {
    if (amount <= 0 || amount > availableToWithdraw.value) return false;

    try {
      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) return false;

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = Endpoint.withdrawalRequests;

      final body = json.encode({'amount': amount});

      final resp = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: body,
      );

      // Debug: log response status and body
      print('🔔 [WITHDRAW] HTTP status: ${resp.statusCode}');
      print('🔔 [WITHDRAW] HTTP body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // Try to decode server message if provided. Some APIs return a
        // 2xx response but include a 'status' field that requires action
        // (e.g. Stripe re-onboarding). Handle that first.
        try {
          final Map<String, dynamic> body = json.decode(resp.body);

          // If the server indicates Stripe re-onboarding is required,
          // open the provided URL and do not mark as a normal success.
          final statusField = (body['status'] ?? '').toString();
          if (statusField == 're_onboarding_required' &&
              body['url'] != null &&
              body['url'].toString().isNotEmpty) {
            final String launchUrl = body['url'].toString();
            EasyLoading.showInfo(
              'Stripe verification required — opening link...',
            );
            print(
              '🔔 [WITHDRAW] Server requested re-onboarding. Launching: $launchUrl',
            );
            try {
              final bool launched = await launchUrlString(
                launchUrl,
                mode: LaunchMode.externalApplication,
              );
              print('🔔 [WITHDRAW] launchUrlString returned: $launched');
              if (!launched) {
                print(
                  '🔔 [WITHDRAW] launch reported false, attempting fallback',
                );
                final bool fallback = await launchUrlString(launchUrl);
                print('🔔 [WITHDRAW] fallback launch returned: $fallback');
              }
            } catch (e, st) {
              print('🔔 [WITHDRAW] Error launching URL: $e\n$st');
              try {
                final bool fallback = await launchUrlString(launchUrl);
                print('🔔 [WITHDRAW] fallback launch returned: $fallback');
              } catch (e2, st2) {
                print('🔔 [WITHDRAW] Fallback also failed: $e2\n$st2');
              }
            }

            return false;
          }

          // Normal success path: update values and show message
          availableToWithdraw.value = (availableToWithdraw.value).clamp(
            0,
            double.infinity,
          );
          pendingClearance.value = pendingClearance.value;

          final msg = body['message'] ?? body['msg'] ?? 'Withdrawal requested';
          EasyLoading.showSuccess(msg.toString());
          print('🔔 [WITHDRAW] Success message: $msg');

          // Refresh withdrawal history and earnings immediately
          fetchWithdrawalHistory();
          fetchEarnings();
          // Also refresh profile screen if available so header updates
          try {
            final profileController = Get.find<ProfileController>();
            profileController.fetchProfile();
          } catch (_) {}
        } catch (e) {
          // If response isn't JSON, proceed with optimistic update
          print('🔔 [WITHDRAW] Success but failed to parse body as JSON: $e');
          availableToWithdraw.value = (availableToWithdraw.value).clamp(
            0,
            double.infinity,
          );
          pendingClearance.value = pendingClearance.value;

          // Refresh history/earnings/profile asynchronously
          fetchWithdrawalHistory();
          fetchEarnings();
          try {
            final profileController = Get.find<ProfileController>();
            profileController.fetchProfile();
          } catch (_) {}
          EasyLoading.showSuccess('Withdrawal request submitted');
        }

        return true;
      }

      // Handle special non-2xx responses: e.g., Stripe re-onboarding required
      try {
        final Map<String, dynamic> errorBody = json.decode(resp.body);
        print('🔔 [WITHDRAW] parsed error body: $errorBody');
        final status = (errorBody['status'] ?? '').toString();
        if (status == 're_onboarding_required' &&
            errorBody['url'] != null &&
            errorBody['url'].toString().isNotEmpty) {
          final String launchUrl = errorBody['url'].toString();
          EasyLoading.showInfo(
            'Stripe verification required — opening link...',
          );
          print('🔔 [WITHDRAW] launching URL: $launchUrl');
          try {
            final bool launched = await launchUrlString(
              launchUrl,
              mode: LaunchMode.externalApplication,
            );
            print('🔔 [WITHDRAW] launchUrlString returned: $launched');
            if (!launched) {
              print('🔔 [WITHDRAW] launch reported false, trying fallback');
              final bool fallback = await launchUrlString(launchUrl);
              print('🔔 [WITHDRAW] fallback launch returned: $fallback');
            }
          } catch (e, st) {
            print('🔔 [WITHDRAW] error launching url: $e\n$st');
            try {
              final bool fallback = await launchUrlString(launchUrl);
              print('🔔 [WITHDRAW] fallback launch returned: $fallback');
            } catch (e2, st2) {
              print('🔔 [WITHDRAW] fallback also failed: $e2\n$st2');
            }
          }
          return false;
        }

        // show server-provided message when available
        final msg = errorBody['message'] ?? errorBody['msg'];
        if (msg != null) {
          EasyLoading.showError(msg.toString());
          print('🔔 [WITHDRAW] server message: $msg');
        }
      } catch (e) {
        // Non-JSON or unknown format — fall through
        print('🔔 [WITHDRAW] failed to parse error body: $e');
        print('🔔 [WITHDRAW] raw body: ${resp.body}');
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
