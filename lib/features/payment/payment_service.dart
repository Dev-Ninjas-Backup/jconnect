import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class PaymentService {
  SharedPreferencesHelperController sharedPreferencesHelper =
      Get.find<SharedPreferencesHelperController>();

  /// 1️⃣ Create SetupIntent
  Future<String> createSetupIntent() async {
    try {
      final token = await sharedPreferencesHelper.getAccessToken() ?? '';

      final response = await http.post(
        Uri.parse(
          "${Endpoint.baseUrl}/payments/create-setup-intent",
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'authorization': token,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          print('createSetupIntent response data: $data');
          if (data == null || data['client_secret'] == null) {
            throw Exception('createSetupIntent returned no client_secret: ${response.body}');




          }
          return data['client_secret'] as String;
          
        } catch (e) {
          throw Exception('Failed to parse createSetupIntent response: ${response.body}');
        }
      }

      throw Exception('Failed to create Setup Intent: ${response.statusCode} - ${response.body}');
    } catch (e) {
      rethrow;
    }
  }

  /// 2️⃣ Confirm SetupIntent
  Future<void> confirmSetupIntent({
    required String clientSecret,
    required String token,
  }) async {
    await http.post(
      Uri.parse(
        'https://jconnect-server.saikat.com.bd/payments/confirm-setup-intent',
      ),
      headers: {
        'Content-Type': 'application/json',

        'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
      },
      body: jsonEncode({'clientSecret': clientSecret, 'token': token}),
    );
  }

  /// 3️⃣ Make Payment
  Future<void> makePayment(String serviceId) async {
    await http.post(
      Uri.parse('https://jconnect-server.saikat.com.bd/payments/make-payment'),
      headers: {
        'Content-Type': 'application/json',

        'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
      },
      body: jsonEncode({'serviceId': serviceId}),
    );
  }
}
