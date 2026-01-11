import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';

class PaymentService {
  final SharedPreferencesHelperController _prefs =
      Get.find<SharedPreferencesHelperController>();

  Future<Map<String, String>> _headers() async {
    return {
      'Content-Type': 'application/json',
      'authorization': await _prefs.getAccessToken() ?? '',
    };
  }

  /// Attach payment method to customer
  Future<void> paymentMethodAdd(String paymentMethodId) async {
    final response = await http.post(
      Uri.parse(
        '${Endpoint.baseUrl}/payments/payment_method_attached'
        '?payment_method_id=$paymentMethodId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Payment method attach failed: ${response.body}');
    }
  }

  /// Make payment for service
  Future<void> makePayment(String serviceId) async {
    final response = await http.post(
      Uri.parse('${Endpoint.baseUrl}/payments/make-payment'),
      headers: await _headers(),
      body: jsonEncode({'serviceId': serviceId}),
    );

    if (kDebugMode) {
      if (kDebugMode) {
        print("make payment response: ${response.body}");
      }
    }
    if (kDebugMode) {
      print(response.statusCode);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Payment failed: ${response.body}');
    }
  }

  Future<PaymentMethodModel> fetchPaymentMethod() async {
    final response = await http.get(
      Uri.parse('${Endpoint.baseUrl}/payments/my-paymentsss-methods'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentMethodModel.fromJson(data);
    } else {
      throw Exception('Failed to load payment method');
    }
  }

  Future<bool> deletePaymentMethod(String? paymentMethodId) async {
    if (paymentMethodId == null || paymentMethodId.isEmpty) {
      return false;
    }

    final response = await http.delete(
      Uri.parse('${Endpoint.baseUrl}/payments/delete-payment-method'),
      headers: await _headers(),
      body: jsonEncode({'paymentMethodId': paymentMethodId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to delete payment method');
    }
  }

  /// Fetch platform fee percentage
  Future<int> fetchPlatformFee() async {
    final response = await http.get(
      Uri.parse('${Endpoint.baseUrl}/settings'),
      headers: await _headers(),
    );

    if (response.statusCode == 200||response.statusCode==201) {
      final data = jsonDecode(response.body);
      return data['platformFee_percents'];
    } else {
      throw Exception('Failed to load platform fee: ${response.body}');
    }
  }
}
